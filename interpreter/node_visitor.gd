class_name NodeVisitor
extends RefCounted

func visit(ast_node: AST):
	# a = 2
	if ast_node is Program:
		return await visit_program(ast_node)
	if ast_node is BinaryOP:
		return await visit_binary_op(ast_node)
	elif ast_node is Number:
		return await visit_number(ast_node)
	elif ast_node is Assignment:
		return await visit_assignment(ast_node)
	elif ast_node is UnaryOp:
		return await visit_unary_op(ast_node)
	elif ast_node is Block:
		return await visit_block(ast_node)
	elif ast_node is VarDecl:
		return await visit_var_decl(ast_node)
	elif ast_node is Var:
		return await visit_var(ast_node)
	elif ast_node is NoOp:
		return await visit_no_op(ast_node)
	elif ast_node is FunctionDecl:
		return await visit_function_decl(ast_node)
	elif ast_node is FunctionCall:
		return await visit_function_call(ast_node)
	elif ast_node is ReturnStatement:
		return await visit_return_statement(ast_node)
	elif ast_node is WhileLoop:
		return await visit_while_loop(ast_node)
	elif ast_node is ForLoop:
		return await visit_for_loop(ast_node)
	elif ast_node is IfStatement:
		return await visit_if_statement(ast_node)
	elif ast_node is ArrayNode:
		return await visit_array_literal(ast_node)
	else:
		push_error("can't visit node, pretending its a noop")
		return await visit_no_op(NoOp.new())

func visit_program(node: Program):
	pass

func visit_if_statement(node: IfStatement):
	pass

func visit_return_statement(node: ReturnStatement):
	pass

func visit_array_literal(ast_node: ArrayNode):
	pass

func visit_for_loop(node: ForLoop):
	pass

func visit_while_loop(node: WhileLoop):
	pass

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
