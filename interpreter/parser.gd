class_name Parser
extends RefCounted

var lexer: Lexer
var current_token: Token

var parser_error: ParserError
var error_pos = 0

enum ParserError {
	OK,
	ERROR
}

func _init(lexer: Lexer):
	self.lexer = lexer
	current_token = lexer.get_next_token()
	parser_error = ParserError.OK

func reset():
	lexer.reset()
	current_token = lexer.get_next_token()
	parser_error = ParserError.OK

func error(from: String):
	print("error from ", from)
	parser_error = ParserError.ERROR

func eat(token_type):
	# compare the current token type with the passed token
	# type and if they match then "eat" the current token
	# and assign the next token to the self.current_token,
	# otherwise raise an exception.
	if current_token.type == token_type:
		current_token = lexer.get_next_token()
	else:
		error("expected {0}".format([Token.TYPE_STRINGS[token_type]]))

func factor() -> AST:
	var token = current_token
	if token.type == Token.Type.LPAREN:
		eat(Token.Type.LPAREN)
		var result = expr()
		eat(Token.Type.RPAREN)
		return result
	elif token.type == Token.Type.INTEGER:
		eat(Token.Type.INTEGER)
		return Number.new(token)
	elif token.type in [Token.Type.MINUS, Token.Type.PLUS]:
		eat(token.type)
		return UnaryOp.new(token, factor())
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

	while self.current_token.type in [Token.Type.PLUS, Token.Type.MINUS]:
		var token = self.current_token
		if token.type == Token.Type.PLUS:
			self.eat(Token.Type.PLUS)
		elif token.type == Token.Type.MINUS:
			self.eat(Token.Type.MINUS)
		
		result = BinaryOP.new(result, token, term())
	return result

func program():
	var node = block()
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

func statement_list():
	var current_statement = statement()
	var result = [current_statement]
	while current_token.type == Token.Type.NL:
		eat(Token.Type.NL)
		result.append(statement())
	if current_token.type == Token.Type.IDENT:
		error("statement list")
	return result

func statement():
	if current_token.type == Token.Type.BEGIN:
		return block()
	elif current_token.type == Token.Type.IDENT:
		return assignment()
	else:
		return empty()

func assignment():
	var left = variable()
	var token = current_token
	eat(Token.Type.ASSIGN)
	var right = expr()
	return Assignment.new(left, right)

func variable():
	var node = Var.new(current_token)
	eat(Token.Type.IDENT)
	return node

func empty():
	return NoOp.new()

func parse():
	var root = Block.new()
	root.children = statement_list()
	return root
