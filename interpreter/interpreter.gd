class_name Interpreter
extends NodeVisitor

var parser: Parser

signal print_requested(arg_list)
signal move_requested(move)

var interpreter_error: InterpreterError
var error_pos = 0

enum InterpreterError {
	OK,
	ERROR
}

var call_stack: CallStack

var ast: AST

signal tick
signal tracepoint(node: AST, call_stack: CallStack)

func _init(parser: Parser):
	self.parser = parser
	call_stack = CallStack.new()
	var ar = ActivationRecord.new(
		"test program",
		ActivationRecord.ARType.PROGRAM,
		1,
		null,
		null
	)
	call_stack.push(ar)

func tracepoint_reached(node: AST):
	tracepoint.emit(node, call_stack.shallow_copy())
	await tick

func reset():
	parser.reset()

func visit_function_decl(node: FunctionDecl):
	var ar = call_stack.peek()
	ar.set_item(node.name.name, node)

func visit_if_statement(node: IfStatement):
	var condition = node.condition
	var block = node.block
	if await visit(condition):
		return await visit(node.block)
	else:
		return await visit(node.else_block)

func visit_while_loop(node: WhileLoop):
	while await visit(node.condition):
		await visit(node.block)

func visit_function_call(node: FunctionCall):
	var ar = call_stack.peek()
	var function_decl: FunctionDecl = ar.get_item(node.name.name)
	if node.name.name == "print":
		var to_print = []
		for arg in node.args:
			to_print.append(await visit(arg))
		print_requested.emit(to_print)
		await tracepoint_reached(node)
		return
	if node.name.name == "move":
		var move = []
		for arg in node.args:
			move.append(await visit(arg))
		move_requested.emit(move.front())
		await tracepoint_reached(node)
		return
	
	#await tracepoint_reached(function_decl)
	var new_ar = ActivationRecord.new(
		function_decl.name.name,
		ActivationRecord.ARType.FUNCTION_CALL,
		ar.nesting_level + 1,
		ar,
		node.token
	)
	
	for i in range(len(function_decl.args)):
		var arg_decl: VarDecl = function_decl.args[i] # x: int
		var arg: AST = node.args[i] 
		var arg_val = await visit(arg) # get the actual value of a
		new_ar.set_item(arg_decl.var_node.name, arg_val) # x: int = value of a
	call_stack.push(new_ar)
	
	await tracepoint_reached(node)
	var result = await visit(function_decl.block)
	#print(call_stack)
	call_stack.pop()
	return result

func visit_binary_op(node: BinaryOP):
	var l = await visit(node.left)
	var r = await visit(node.right)
	await tracepoint_reached(node)
	if node.op.type == Token.Type.PLUS:
		return l + r
	elif node.op.type == Token.Type.MINUS:
		return l - r
	elif node.op.type == Token.Type.MUL:
		return l * r
	elif node.op.type == Token.Type.DIV:
		return l / r
	elif node.op.type == Token.Type.LESS_THAN:
		return l < r
	elif node.op.type == Token.Type.GREATER_THAN:
		return l > r

func visit_unary_op(node: UnaryOp):
	if node.op.type == Token.Type.MINUS:
		return -1 * await visit(node.right)
	if node.op.type == Token.Type.PLUS:
		return await visit(node.right)

func visit_number(node: Number):
	return node.value

func visit_assignment(node: Assignment):
	var left_name = node.left.name
	var var_value = await visit(node.right)
	
	var ar = call_stack.peek()
	ar.set_item(left_name, var_value)
	#print("assignment {0} = {1}".format([node.left.name,var_value]))
	await tracepoint_reached(node)

func visit_block(node: Block):
	for child in node.children:
		if child is ReturnStatement:
			return await visit(child)
		if call_stack.peek().should_return:
			return call_stack.peek().return_val
		await visit(child)

func visit_return_statement(node: ReturnStatement):
	var ar = call_stack.peek()
	var result = await visit(node.right)
	ar.set_return(result)
	await tracepoint_reached(node)
	return result

func visit_var_decl(node: VarDecl):
	await tracepoint_reached(node)

func visit_var(node: Var):
	var ar = call_stack.peek()
	return ar.get_item(node.name)

func visit_no_op(node: NoOp):
	return

func print_ast(node: AST, indent: int = 0):
	parser.reset()
	var indent_str = " ".repeat(indent)
	if node is BinaryOP:
		print("{0}BinaryOP: {1}".format([indent_str, node.op.value]))
		print_ast(node.left, indent + 2)
		print_ast(node.right, indent + 2)
	elif node is Number:
		print("{0}Number: {1}".format([indent_str, node.value]))
	elif node is Assignment:
		print("{0}Assignment:".format([indent_str]))
		print_ast(node.left, indent + 2)
		print_ast(node.right, indent + 2)
	elif node is UnaryOp:
		print("{0}UnaryOp: {1}".format([indent_str, node.op.value]))
		print_ast(node.right, indent + 2)
	elif node is Block:
		print("{0}Block:".format([indent_str]))
		for child in node.children:
			print_ast(child, indent + 2)
	elif node is VarDecl:
		print("{0}VarDecl: {1}:{2}".format([indent_str,node.var_node.name,node.type_node.type_name]))
	elif node is Var:
		print("{0}Var: {1}".format([indent_str,node.name]))
	elif node is FunctionDecl:
		print("{0}FunctionDecl: {1}".format([indent_str, node.name.name]))
		print("{0}Args:".format([indent_str]))
		for arg in node.args:
			print_ast(arg,indent + 2)
		print_ast(node.block, indent + 2)
	elif node is FunctionCall:
		print("{0}FunctionCall: {1}".format([indent_str, node.name.name]))
		for arg in node.args:
			print_ast(arg,indent + 2)
		#print_ast(node.block, indent + 2)
	elif node is IndexOp:
		print("{0}Index:".format([indent_str]))
		print_ast(node.left, indent + 2)
		print_ast(node.index, indent + 2)
	elif node is ArrayNode:
		print("{0}ArrayDecl: ".format([indent_str]))
		for item in node.items:
			print_ast(item, indent + 2)
	elif node is AttributeAccess:
		print("{0}Attribute: ".format([indent_str]))
		print_ast(node.parent, indent + 2)
		print_ast(node.member, indent + 2)
	elif node is IfStatement:
		print("{0}If:".format([indent_str]))
		print_ast(node.condition, indent + 2)
		print_ast(node.block, indent + 2)
	elif node is ForLoop:
		print("{0}ForLoop:".format([indent_str]))
		indent_str = indent_str + " ".repeat(2)
		print("{0}Var:".format([indent_str]))
		print_ast(node.identifier, indent + 4)
		print("{0}Iterable:".format([indent_str]))
		print_ast(node.iterable, indent + 4)
		print_ast(node.block, indent + 2)
	elif node is WhileLoop:
		print("{0}WhileLoop:".format([indent_str]))
		indent_str = indent_str + " ".repeat(2)
		print("{0}Condition:".format([indent_str]))
		print_ast(node.condition, indent + 4)
		print_ast(node.block, indent + 2)
	elif node is NoOp:
		print("{0}NoOp".format([indent_str]))
	else:
		print("{0}Unknown node type: {1}".format([indent_str, node]))
