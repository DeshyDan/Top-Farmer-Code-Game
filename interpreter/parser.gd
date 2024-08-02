class_name Parser
extends RefCounted

var lexer: Lexer
var current_token: Token

var parser_error: GError
var error_pos = 0

enum ParserError {
	OK,
	ERROR
}

func _init(lexer: Lexer):
	self.lexer = lexer
	current_token = lexer.get_next_token()
	parser_error = GError.new(GError.ErrorCode.OK)

func reset():
	lexer.reset()
	current_token = lexer.get_next_token()
	parser_error = GError.new(GError.ErrorCode.OK)

func error(error_code, token: Token, expected: Token):
	parser_error = GError.new(
		error_code,
		token,
		"Expected {0}".format([expected])
	)
	#current_token = Token.new(token.Type.EOF, null)



func eat(token_type):
	# compare the current token type with the passed token
	# type and if they match then "eat" the current token
	# and assign the next token to the self.current_token,
	# otherwise raise an exception.
	if current_token.type == token_type:
		current_token = lexer.get_next_token()
	else:
		error(GError.ErrorCode.UNEXPECTED_TOKEN,
				current_token,
				Token.new(token_type, null))

func factor() -> AST:
	var token = current_token
	if token.type == Token.Type.LPAREN:
		eat(Token.Type.LPAREN)
		var result = expr()
		eat(Token.Type.RPAREN)
		return result
	elif token.type == Token.Type.INTEGER_CONST:
		eat(Token.Type.INTEGER_CONST)
		return Number.new(token)
	elif token.type == Token.Type.REAL_CONST:
		eat(Token.Type.REAL_CONST)
		return Number.new(token)
	elif token.type in [Token.Type.MINUS, Token.Type.PLUS]:
		eat(token.type)
		return UnaryOp.new(token, factor())
	elif current_token.type == Token.Type.IDENT and lexer.current_char == "(":
		return func_call()
	else:
		return variable()


func term() -> AST:
	var result = factor()

	while current_token.type in [Token.Type.MUL, Token.Type.DIV]:
		var token = self.current_token
		if token.type == Token.Type.MUL:
			self.eat(Token.Type.MUL)
		elif token.type == Token.Type.DIV:
			self.eat(Token.Type.DIV)
		result = BinaryOP.new(result,token,factor())

	return result

func expr():
	var result = term()

	while self.current_token.type in [Token.Type.PLUS, Token.Type.MINUS, Token.Type.LESS_THAN, Token.Type.GREATER_THAN]:
		var token = self.current_token
		if token.type == Token.Type.PLUS:
			self.eat(Token.Type.PLUS)
		elif token.type == Token.Type.MINUS:
			self.eat(Token.Type.MINUS)
		elif token.type == Token.Type.LESS_THAN:
			eat(Token.Type.LESS_THAN)
		elif token.type == Token.Type.GREATER_THAN:
			eat(Token.Type.GREATER_THAN)
		
		
		result = BinaryOP.new(result, token, term())
	return result

func program():
	var node = statement_list()
	eat(Token.Type.EOF)
	return node

func block():
	var root = Block.new()
	eat(Token.Type.BEGIN)
	var nodes = statement_list()
	eat(Token.Type.END)
	for node in nodes:
		root.children.append(node)
	return root

func while_loop():
	eat(Token.Type.WHILE)
	var condition_node = expr()
	eat(Token.Type.COLON)
	eat(Token.Type.NL)
	var block_node = block()
	return WhileLoop.new(condition_node, block_node)

func if_statement():
	eat(Token.Type.IF)
	var condition_node = expr()
	eat(Token.Type.COLON)
	eat(Token.Type.NL)
	var block_node = block()
	return IfStatement.new(condition_node, block_node)

func statement_list():
	var current_statement = statement()
	var result = [current_statement]
	while current_token.type == Token.Type.NL:
		eat(Token.Type.NL)
		result.append(statement())
	if current_token.type == Token.Type.IDENT:
		error(GError.ErrorCode.ID_NOT_FOUND,current_token,null)
	return result

func statement():
	if current_token.type == Token.Type.BEGIN:
		return block()
	elif current_token.type == Token.Type.IDENT and lexer.current_char == "(":
		return func_call()
	elif current_token.type == Token.Type.VAR:
		return var_decl()
	elif current_token.type == Token.Type.IDENT:
		return assignment()
	elif current_token.type == Token.Type.FUNC:
		return func_decl()
	elif current_token.type == Token.Type.WHILE:
		return while_loop()
	elif current_token.type == Token.Type.IF:
		return if_statement()
	elif current_token.type == Token.Type.RETURN:
		return return_statement()
	else:
		return empty()

func return_statement():
	eat(Token.Type.RETURN)
	var right_node = NoOp.new()
	if current_token.type != Token.Type.NL:
		right_node = expr()
	return ReturnStatement.new(right_node)

func assignment():
	# 2
	var left = variable()
	# -<<
	var token = current_token
	eat(Token.Type.ASSIGN)
	var right = expr()
	return Assignment.new(left, right)

func var_decl():
	eat(Token.Type.VAR)
	var variable = variable()
	eat(Token.Type.COLON)
	var type = type_spec()
	return VarDecl.new(variable,type)

func variable():
	var node = Var.new(current_token)
	eat(Token.Type.IDENT)
	return node

func type_spec():
	var token = current_token
	if current_token.type == Token.Type.INTEGER:
		eat(Token.Type.INTEGER)
	else:
		eat(Token.Type.FLOAT)
	var node = Type.new(token)
	return node

func func_decl():
	eat(Token.Type.FUNC)
	var func_name = variable()
	eat(Token.Type.LPAREN)
	var args: Array[VarDecl] = []
	while current_token.type != current_token.Type.RPAREN:
		var arg_name = variable()
		eat(Token.Type.COLON)
		var arg_type = type_spec()
		args.append(VarDecl.new(arg_name,arg_type))
		if current_token.type == current_token.Type.RPAREN:
			break
		eat(Token.Type.COMMA)
	eat(Token.Type.RPAREN)
	eat(Token.Type.COLON)
	eat(Token.Type.NL)
	var block = block()
	return FunctionDecl.new(func_name, args, block)

func func_call():
	var function = variable()
	eat(Token.Type.LPAREN)
	var args = []
	while current_token.type != current_token.Type.RPAREN:
		var arg = expr()
		args.append(arg)
		if current_token.type == current_token.Type.RPAREN:
			break
		eat(Token.Type.COMMA)
	eat(Token.Type.RPAREN)
	#eat(Token.Type.LPAREN)
	return FunctionCall.new(function, args, function.token)

func empty():
	return NoOp.new()

func peek(offset = 1):
	return lexer.get_next_token()

func parse():
	var root = Block.new()
	root.children = statement_list()
	return root
