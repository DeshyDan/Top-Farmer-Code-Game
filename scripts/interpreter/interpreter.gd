class_name Interpreter
extends NodeVisitor

var parser: Parser

signal print_requested(arg_list)
signal move_requested(move)
signal plant_requested(plant)

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
signal finished

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
		if call_stack.peek().should_return:
			return call_stack.peek().return_val
		await visit(node.block)

func visit_for_loop(node: ForLoop):
	var identifier: Var = node.identifier
	var ar = call_stack.peek()
	for item in (await visit(node.iterable)):
		await tracepoint_reached(node)
		if call_stack.peek().should_return:
			return call_stack.peek().return_val
		ar.set_item(identifier.name, item)
		var result = await visit(node.block)

func visit_array_literal(node: ArrayNode):
	var result = []
	for item_node in node.items:
		result.append(await visit(item_node))
	return result

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
	if node.name.name == "plant":
		var move = []
		for arg in node.args:
			move.append(await visit(arg))
		plant_requested.emit(move.front())
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
	var ret_val = call_stack.peek().return_val
	call_stack.pop()
	return ret_val

func visit_binary_op(node: BinaryOP):
	var l = await visit(node.left)
	var r = await visit(node.right)
	await tracepoint_reached(node)
	match node.op.type:
		Token.Type.PLUS:
			return l + r
		Token.Type.MINUS:
			return l - r
		Token.Type.MUL:
			return l * r
		Token.Type.DIV:
			return l / r
		Token.Type.MOD:
			return l % r
		Token.Type.LESS_THAN:
			return l < r
		Token.Type.IS_EQUAL:
			return l == r
		Token.Type.LT_OR_EQ:
			return l <= r
		Token.Type.GREATER_THAN:
			return l > r
		Token.Type.GT_OR_EQ:
			return l >= r
		Token.Type.LOGIC_AND:
			return l and r
		Token.Type.LOGIC_OR:
			return l or r
	push_error("unrecognized binary operation: %s" % str(node.op.value))

func visit_unary_op(node: UnaryOp):
	if node.op.type == Token.Type.MINUS:
		return -1 * await visit(node.right)
	if node.op.type == Token.Type.PLUS:
		return await visit(node.right)
	if node.op.type == Token.Type.LOGIC_NOT:
		return not await visit(node.right)

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
			var ret_val = await visit(child.right)
			call_stack.peek().set_return(ret_val)
			return ret_val
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

func visit_program(node: Program):
	await visit(node.block)
	finished.emit()
