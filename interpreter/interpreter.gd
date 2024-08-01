class_name Interpreter
extends NodeVisitor

var parser: Parser

signal print_requested(arg_list)

var interpreter_error: InterpreterError
var error_pos = 0

enum InterpreterError {
	OK,
	ERROR
}

var variables = {}
var functions = {}
var ast: AST

func _init(parser: Parser):
	self.parser = parser

func reset():
	parser.reset()

#func visit(ast_node: AST):
	## a = 2
	#if ast_node is BinaryOP:
		#return visit_binary_op(ast_node)
	#elif ast_node is Number:
		#return visit_number(ast_node)
	#elif ast_node is Assignment:
		#return visit_assignment(ast_node)
	#elif ast_node is UnaryOp:
		#return visit_unary_op(ast_node)
	#elif ast_node is Block:
		#return visit_block(ast_node)
	#elif ast_node is VarDecl:
		#return visit_vardecl(ast_node)
	#elif ast_node is Var:
		#return visit_var(ast_node)
	#elif ast_node is NoOp:
		#return visit_no_op(ast_node)
	#elif ast_node is FunctionDecl:
		#return visit_function_decl(ast_node)
	#elif ast_node is FunctionCall:
		#return visit_function_call(ast_node)
	#else:
		#print("can't visit node")

func visit_function_decl(node: FunctionDecl):
	variables[node.name.name] = node

func visit_function_call(node: FunctionCall):
	if node.name.name == "print":
			print_requested.emit(node.args.map(func (arg: AST): return visit(arg)))
			return
	
	if variables.has(node.name.name):
		var function_decl: FunctionDecl = variables[node.name.name]
		var new_block = Block.new()
		if len(function_decl.args) != len(node.args):
			print("argument length error")
		for i in range(len(function_decl.args)):
			var arg_decl: VarDecl = function_decl.args[i]
			var arg = node.args[i]
			new_block.children.append(arg_decl)
			var assignment = Assignment.new(arg_decl.var_node,arg)
			new_block.children.append(assignment)
		
		for statement in function_decl.block.children:
			new_block.children.append(statement)
		
		return visit(new_block)

func visit_binary_op(node: BinaryOP):
	if node.op.type == Token.Type.PLUS:
		return visit(node.left) + visit(node.right)
	elif node.op.type == Token.Type.MINUS:
		return visit(node.left) - visit(node.right)
	elif node.op.type == Token.Type.MUL:
		return visit(node.left) * visit(node.right)
	elif node.op.type == Token.Type.DIV:
		var right_eval = visit(node.right)
		if right_eval == 0:
			interpreter_error = InterpreterError.ERROR
			return visit(node.left)
		return visit(node.left) / visit(node.right)

func visit_unary_op(node: UnaryOp):
	if node.op.type == Token.Type.MINUS:
		return -1 * visit(node.right)
	if node.op.type == Token.Type.PLUS:
		return visit(node.right)

func visit_number(node: Number):
	return node.value

func visit_assignment(node: Assignment):
	variables[node.left.name] = visit(node.right)
	print("assignment {0} = {1}".format([node.left.name,visit(node.right)]))

func visit_block(node: Block):
	for child in node.children:
		visit(child)

func visit_var_decl(node: VarDecl):
	pass

func visit_var(node: Var):
	return variables[node.name]

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
	elif node is NoOp:
		print("{0}NoOp".format([indent_str]))
	else:
		print("{0}Unknown node type: {1}".format([indent_str, node]))
