class_name NodeVisitor
extends RefCounted

func visit(ast_node: AST):
	# a = 2
	if ast_node is BinaryOP:
		return visit_binary_op(ast_node)
	elif ast_node is Number:
		return visit_number(ast_node)
	elif ast_node is Assignment:
		return visit_assignment(ast_node)
	elif ast_node is UnaryOp:
		return visit_unary_op(ast_node)
	elif ast_node is Block:
		return visit_block(ast_node)
	elif ast_node is VarDecl:
		return visit_var_decl(ast_node)
	elif ast_node is Var:
		return visit_var(ast_node)
	elif ast_node is NoOp:
		return visit_no_op(ast_node)
	elif ast_node is FunctionDecl:
		return visit_function_decl(ast_node)
	elif ast_node is FunctionCall:
		return visit_function_call(ast_node)
	else:
		print("can't visit node")

func visit_function_decl(node: FunctionDecl):
	pass

func visit_function_call(node: FunctionCall):
	pass

func visit_binary_op(node: BinaryOP):
	pass

func visit_unary_op(node: UnaryOp):
	pass

func visit_number(node: Number):
	pass

func visit_assignment(node: Assignment):
	pass

func visit_block(node: Block):
	pass

func visit_var_decl(node: VarDecl):
	pass

func visit_var(node: Var):
	pass

func visit_no_op(node: NoOp):
	pass
