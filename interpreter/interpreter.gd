class_name Interpreter
extends RefCounted

var parser: Parser

var interpreter_error: InterpreterError
var error_pos = 0

enum InterpreterError {
	OK,
	ERROR
}

var variables = {}
var ast: AST

func _init(parser: Parser):
	self.parser = parser

func reset():
	parser.reset()

func visit(ast_node: AST):
	if ast_node is BinaryOP:
		return visit_BinaryOp(ast_node)
	elif ast_node is Number:
		return visit_Number(ast_node)
	elif ast_node is Assignment:
		return visit_assignment(ast_node)
	elif ast_node is UnaryOp:
		return visit_unary_op(ast_node)
	elif ast_node is Block:
		return visit_block(ast_node)
	elif ast_node is Var:
		return visit_var(ast_node)
	elif ast_node is NoOp:
		return visit_no_op(ast_node)
	else:
		print("can't visit node")

func visit_function_decl(node: FunctionDecl):
	variables[node.name] = node.block

func visit_BinaryOp(node: BinaryOP):
	if node.op.type == Token.Type.PLUS:
		return visit(node.left) + visit(node.right)
	elif node.op.type == Token.Type.MINUS:
		return visit(node.left) - visit(node.right)
	elif node.op.type == Token.Type.MUL:
		return visit(node.left) * visit(node.right)
	elif node.op.type == Token.Type.DIV:
		return visit(node.left) / visit(node.right)

func visit_unary_op(node: UnaryOp):
	if node.op.type == Token.Type.MINUS:
		return -1 * visit(node.right)
	if node.op.type == Token.Type.PLUS:
		return visit(node.right)

func visit_Number(node: Number):
	return node.value

func visit_assignment(node: Assignment):
	variables[node.left.name] = visit(node.right)
	print("assignment {0} = {1}".format([node.left.name,visit(node.right)]))

func visit_block(node: Block):
	for child in node.children:
		visit(child)

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
		print("{0}Assignment: {1}".format([indent_str]))
		print_ast(node.left, indent + 2)
		print_ast(node.right, indent + 2)
	elif node is UnaryOp:
		print("{0}UnaryOp: {1}".format([indent_str, node.op.value]))
		print_ast(node.right, indent + 2)
	elif node is Block:
		print("{0}Block:".format([indent_str]))
		for child in node.children:
			print_ast(child, indent + 2)
	elif node is Var:
		print("{0}Var: {1}".format([indent_str,node.name]))
	elif node is NoOp:
		print("{0}NoOp".format([indent_str]))
	else:
		print("{0}Unknown node type: {1}".format([indent_str]))
