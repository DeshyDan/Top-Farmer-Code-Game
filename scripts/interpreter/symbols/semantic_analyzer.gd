class_name SemanticAnalyzer
extends NodeVisitor

var current_scope: SymbolTable
var semantic_error: SemanticError

func _init():
	current_scope = SymbolTable.new("global", 1, null)
	semantic_error = SemanticError.new(GError.ErrorCode.OK)

func error(from, error_code: GError.ErrorCode, token: Token):
	print("ERROR LINE {0}: {1}".format([token.lineno,token]))
	semantic_error = SemanticError.new(
		error_code,
		token,
		from
		)

func visit_block(node: Block):
	for statement in node.children:
		visit(statement)

func visit_return_statement(node: ReturnStatement):
	if current_scope.enclosing_scope == null:
		error("Return statement in main body", GError.ErrorCode.UNEXPECTED_TOKEN, node.token)

func visit_var_decl(node: VarDecl):
	var type_name = node.type_node.type_name
	var type_symbol = current_scope.lookup(type_name)
	
	var var_name = node.var_node.name
	var var_symbol = VarSymbol.new(var_name, type_symbol)
	if current_scope.lookup(var_name) != null:
		error("Duplicate variable declaration", GError.ErrorCode.DUPLICATE_ID, node.var_node.token)
	current_scope.define(var_symbol)

func visit_var(node: Var):
	var var_name = node.name
	var var_symbol = current_scope.lookup(var_name)
	if var_symbol == null:
		error("Symbol not defined", GError.ErrorCode.ID_NOT_FOUND, node.token)

func visit_assignment(node: Assignment):
	var var_name = node.left.name
	var var_symbol = current_scope.lookup(var_name)
	if var_symbol == null:
		error("Symbol not defined", GError.ErrorCode.ID_NOT_FOUND, node.left.token)
	visit(node.right)

func visit_function_decl(node: FunctionDecl):
	var new_scope_name = node.name.name
	var func_symbol = FunctionSymbol.new(new_scope_name)
	current_scope.define(func_symbol)
	var function_scope = SymbolTable.new(
		new_scope_name,
		current_scope.scope_level + 1,
		current_scope
	)
	current_scope = function_scope
	
	for param: VarDecl in node.args:
		var param_type = current_scope.lookup(param.type_node.type_name)
		var param_name = param.var_node.name
		var var_symbol = VarSymbol.new(param_name,param_type)
		current_scope.define(var_symbol)
		func_symbol.params.append(var_symbol)

	visit(node.block)
	current_scope = function_scope.enclosing_scope
	print("func scope: {0}".format([function_scope]))

func visit_function_call(node: FunctionCall):
	var func_symbol: Symbol = current_scope.lookup(node.name.name)
	if not func_symbol:
		error("Undefined function",
					GError.ErrorCode.UNEXPECTED_TOKEN,
					node.token
					)
		return
	if len(node.args) != len(func_symbol.params):
		error("Arg count mismatch",
				GError.ErrorCode.UNEXPECTED_TOKEN,
				node.token
				)
		return
	for arg in node.args:
		visit(arg)

func visit_program(node):
	visit(node.block)

func visit_binary_op(node):
	visit(node.left)
	visit(node.right)

func visit_unary_op(node):
	visit(node.right)
