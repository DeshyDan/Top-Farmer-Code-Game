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

# TODO: cleanup!!!

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
	current_token = Token.new(token.Type.EOF, null)

func eat(token_type) -> bool:
	# compare the current token type with the passed token
	# type and if they match then "eat" the current token
	# and assign the next token to the self.current_token,
	# otherwise set error and pretend we're at EOF.
	# return a bool in case someone needs to proceed 
	# conditionally
	if current_token.type == token_type:
		current_token = lexer.get_next_token()
		return true
	else:
		error(GError.ErrorCode.UNEXPECTED_TOKEN,
				current_token,
				Token.new(token_type, null))
		return false
		#current_token = Token.new(Token.Type.EOF, "EOF")

func for_statement():
	eat(Token.Type.FOR)
	var identifier = variable()
	eat(Token.Type.IN)
	var iterable = expr()
	eat(Token.Type.COLON)
	var block = statement_or_suite()
	return ForLoop.new(identifier, iterable, block)

func array_decl():
	var result = ArrayNode.new()
	eat(Token.Type.LSQUARE)
	if current_token.type == Token.Type.RSQUARE:
		eat(Token.Type.RSQUARE)
		return result
	var first = expr()
	result.items.append(first)
	while current_token.type == Token.Type.COMMA:
		eat(Token.Type.COMMA)
		result.items.append(expr())
	eat(Token.Type.RSQUARE)
	return result

func literal():
	var token = current_token
	if token.type == Token.Type.LPAREN:
		eat(Token.Type.LPAREN)
		var result = expr()
		eat(Token.Type.RPAREN)
		return result
	elif token.type == Token.Type.LSQUARE:
		return array_decl()
	elif token.type == Token.Type.INTEGER_CONST:
		eat(Token.Type.INTEGER_CONST)
		return Number.new(token)
	elif token.type == Token.Type.REAL_CONST:
		eat(Token.Type.REAL_CONST)
		return Number.new(token)
	elif token.type == Token.Type.TRUE:
		eat(Token.Type.TRUE)
		return Number.new(token) #TODO: bool literal leaf node
	elif token.type == Token.Type.FALSE:
		eat(Token.Type.FALSE)
		return Number.new(token) #TODO: bool literal leaf node
	elif token.type == Token.Type.NULL:
		eat(Token.Type.NULL)
		return NoOp.new() # TODO: null leaf node
	elif token.type == Token.Type.PI_CONST:
		eat(Token.Type.PI_CONST)
		return Number.new(token)
	else:
		return variable()

func subscription():
	var result = literal()
	if current_token.type == Token.Type.LSQUARE:
		var index_token = current_token
		eat(Token.Type.LSQUARE)
		result = IndexOp.new(result, index_token, expr())
		eat(Token.Type.RSQUARE)
	return result
	
func attribute():
	var result = subscription()
	while current_token.type == Token.Type.DOT: # allow chaining attribute
		var dot_token = current_token
		eat(Token.Type.DOT)
		result = AttributeAccess.new(result, dot_token, variable())
	return result

func factor() -> AST:
	var token = current_token
	if token.type in [Token.Type.MINUS, Token.Type.PLUS]:
		eat(token.type)
		return UnaryOp.new(token, factor())
	elif current_token.type == Token.Type.IDENT and lexer.current_char == "(":
		return func_call()
	else:
		return attribute()

func term() -> AST:
	var result = factor()
	
	while current_token.type in [Token.Type.MUL, Token.Type.DIV, Token.Type.MOD]:
		var token = self.current_token
		if token.type == Token.Type.MUL:
			self.eat(Token.Type.MUL)
		elif token.type == Token.Type.DIV:
			self.eat(Token.Type.DIV)
		elif token.type == Token.Type.MOD:
			self.eat(Token.Type.MOD)
		result = BinaryOP.new(result,token,factor())

	return result

func minus():	# TODO: maybe need to change precedence here?
	var result = term()

	while self.current_token.type in [Token.Type.PLUS, Token.Type.MINUS]:
		var token = self.current_token
		if token.type == Token.Type.PLUS:
			self.eat(Token.Type.PLUS)
		elif token.type == Token.Type.MINUS:
			self.eat(Token.Type.MINUS)
		
		result = BinaryOP.new(result, token, term())
	return result

func comparison():
	var result = minus()
	while current_token.type in [Token.Type.LESS_THAN, # allow chaining of comparisons
							  Token.Type.LT_OR_EQ,
							  Token.Type.GREATER_THAN,
							  Token.Type.GT_OR_EQ,
							  Token.Type.IS_EQUAL,
							  Token.Type.IS_NOT_EQUAL]:
		var op_token = current_token
		eat(current_token.type)
		result = BinaryOP.new(result, op_token, minus())
	return result
	

func logic_not():
	if current_token.type == Token.Type.LOGIC_NOT:
		var op_token = current_token
		eat(Token.Type.LOGIC_NOT)
		return UnaryOp.new(op_token, logic_not())
	return comparison()

func logic_and():
	var result = logic_not()
	
	while current_token.type == Token.Type.LOGIC_AND:
		var op_token = current_token
		eat(Token.Type.LOGIC_AND)
		result = BinaryOP.new(result, op_token, logic_not())
	return result

func logic_or():
	var result = logic_and()
	
	while current_token.type == Token.Type.LOGIC_OR:
		var op_token = current_token
		eat(Token.Type.LOGIC_OR)
		result = BinaryOP.new(result, op_token, logic_and())
	return result

func expr():
	var result = logic_or()
	if current_token.type == Token.Type.LSQUARE:
		var op_token = current_token
		eat(Token.Type.LSQUARE)
		var index = expr()
		eat(Token.Type.RSQUARE)
		result = IndexOp.new(result, op_token, index)
	return result

func program():
	var node = statement_list()
	eat(Token.Type.EOF)
	return node

func while_loop():
	eat(Token.Type.WHILE)
	var condition_node = expr()
	eat(Token.Type.COLON)
	#eat(Token.Type.NL)
	var block_node = statement_or_suite()
	return WhileLoop.new(condition_node, block_node)

func if_statement():
	eat(Token.Type.IF)
	var condition_node = expr()
	eat(Token.Type.COLON)
	#eat(Token.Type.NL)
	var block_node = statement_or_suite()
	var else_block = Block.new()
	if current_token.type == Token.Type.ELSE:
		eat(Token.Type.ELSE)
		eat(Token.Type.COLON)
		else_block = statement_or_suite()
	return IfStatement.new(condition_node, block_node, else_block)

func statement_list():
	var current_statement = statement()
	var result = [current_statement]
	while current_token.type == Token.Type.NL:
		eat(Token.Type.NL)
		result.append(statement())
	#if current_token.type == Token.Type.IDENT:
		#error(GError.ErrorCode.ID_NOT_FOUND,current_token,null)
	return result

func statement_or_suite():
	var block = Block.new()
	if current_token.type == Token.Type.NL:
		eat(Token.Type.NL)
		eat(Token.Type.BEGIN)
		block.children = suite()
		eat(Token.Type.END)
	else:
		block.children = [statement()]
	return block

func suite():
	var current_statement = statement()
	var result = [current_statement]
	while current_token.type != Token.Type.END and current_token.type != Token.Type.EOF:
		result.append(statement())
	return result

func statement():
	#if current_token.type == Token.Type.BEGIN:
		#return block()
	if current_token.type == Token.Type.IDENT and lexer.current_char == "(":
		var result = func_call()
		eat(Token.Type.NL)
		return result
	elif current_token.type == Token.Type.VAR:
		return var_decl()
	elif current_token.type == Token.Type.IDENT:
		return assignment()
	elif current_token.type == Token.Type.FUNC:
		return func_decl()
	elif current_token.type == Token.Type.FOR:
		return for_statement()
	elif current_token.type == Token.Type.WHILE:
		return while_loop()
	elif current_token.type == Token.Type.IF:
		return if_statement()
	elif current_token.type == Token.Type.RETURN:
		return return_statement()
	elif current_token.type == Token.Type.END or current_token.type == Token.Type.EOF:
		return empty()
	else:
		error(GError.ErrorCode.UNEXPECTED_TOKEN,
				current_token,
				Token.new(current_token.type, null))
		current_token = Token.new(Token.Type.EOF, "EOF")

func return_statement():
	var ret_token = current_token
	eat(Token.Type.RETURN)
	var right_node = NoOp.new()
	if current_token.type != Token.Type.NL:
		right_node = expr()
	eat(Token.Type.NL)
	return ReturnStatement.new(right_node, ret_token)

func assignment():
	# 2
	var left = subscription()
	# -<<
	var token = current_token
	eat(Token.Type.ASSIGN)
	var right = expr()
	eat(Token.Type.NL)
	return Assignment.new(left, right, token)

func var_decl():
	eat(Token.Type.VAR)
	var variable = variable()
	if not eat(Token.Type.COLON):
		return
	var type = type_spec()
	if not eat(Token.Type.NL):
		return
	return VarDecl.new(variable,type)

func variable():
	var token = current_token
	if not eat(Token.Type.IDENT):
		return
	var node = Var.new(token)
	return node

func type_spec():
	var token = current_token
	if current_token.type == Token.Type.INTEGER:
		eat(Token.Type.INTEGER)
	elif current_token.type == Token.Type.FLOAT:
		eat(Token.Type.FLOAT)
	else:
		return
	var node = Type.new(token)
	return node

func func_decl():
	eat(Token.Type.FUNC)
	var func_name = variable()
	eat(Token.Type.LPAREN)
	var args: Array[VarDecl] = []
	while current_token.type != current_token.Type.RPAREN and current_token.type != current_token.Type.EOF:
		var arg_name = variable()
		eat(Token.Type.COLON)
		var arg_type = type_spec()
		args.append(VarDecl.new(arg_name,arg_type))
		if current_token.type == current_token.Type.RPAREN:
			break
		eat(Token.Type.COMMA)
	eat(Token.Type.RPAREN)
	eat(Token.Type.COLON)
	#eat(Token.Type.NL)
	var block = statement_or_suite()
	return FunctionDecl.new(func_name, args, block)

func func_call():
	var function = attribute()
	eat(Token.Type.LPAREN)
	var args = []
	while current_token.type != current_token.Type.RPAREN:
		var arg = expr()
		args.append(arg)
		if current_token.type == current_token.Type.RPAREN:
			break
		eat(Token.Type.COMMA)
	eat(Token.Type.RPAREN)
	return FunctionCall.new(function, args, function.token)

func empty():
	return NoOp.new()

func peek(offset = 1):
	return lexer.get_next_token()

func parse():
	var root = Block.new()
	root.children = suite()
	return Program.new(root)
