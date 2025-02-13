class_name Lexer
extends RefCounted

# Lexical analyzer (also known as scanner or tokenizer).
# Pass a source code string into the constructor and call
# get_next_token() to get the next token object in the 
# source code.

var pos: int
var text: String
var current_char: Variant

var lexer_error: LexerError
var error_pos = 0

# Indentation stack is used
# to push/pop indentation levels.
var indent_stack = []

# Number of indents we have to
# return before finding the next token
var pending_indents = 0

var keywords = {
	"var": Token.Type.VAR,
	"int": Token.Type.INTEGER,
	"float": Token.Type.FLOAT,
	"func": Token.Type.FUNC,
	"while": Token.Type.WHILE,
	"return": Token.Type.RETURN,
	"break": Token.Type.BREAK,
	"continue": Token.Type.CONTINUE,
	"if": Token.Type.IF,
	"else": Token.Type.ELSE,
	"and": Token.Type.LOGIC_AND,
	"or": Token.Type.LOGIC_OR,
	"not": Token.Type.LOGIC_NOT,
	"for": Token.Type.FOR,
	"in": Token.Type.IN,
	"true": Token.Type.TRUE,
	"false": Token.Type.FALSE,
	"null": Token.Type.NULL,
	#"print": Token.Type.PRINT,
}
const keyword_data_path = "res://keywords.json"

func count_indentation(line):
	#"""Count the number of leading spaces or tabs in a line."""
	var count = 0
	for char in line:
		if char in [' ', '\t']:
			count += 1
		else:
			break
	return count

func _init(text: String):
	self.text = text
	pos = 0
	if text == "":
		current_char = null
	else:
		current_char = self.text[pos]
	lexer_error = LexerError.new(LexerError.ErrorCode.OK, null, "OK")

func reset():
	pos = 0
	current_char = text[pos]
	lexer_error = LexerError.new(LexerError.ErrorCode.OK)
	pending_newline = false
	line_number = 0
	col_number = 0
	tab_size = 4
	pending_indents = 0

func error(from: String):
	var fake_token = Token.new(Token.Type.IDENT, current_char, line_number, col_number)
	var message = get_error_text()
	lexer_error = LexerError.new(LexerError.ErrorCode.INVALID_CHAR,
								 fake_token,
								 message)
	error_pos = pos
	current_char = null

func get_error_text() -> String:
	var result = ""
	match lexer_error:
		LexerError.ErrorCode.OK:
			result = "no error"
		_:
			result = "invalid char"
	return result

func advance():
	#"""Advance the 'pos' pointer and set the 'current_char' variable."""
	pos += 1
	col_number += 1
	if pos > len(text) - 1:
		current_char = null  # Indicates end of input
		newline(true) # add newline at end of input no matter what
		check_indent()
	else:
		current_char = text[self.pos]

var pending_newline = false
var last_newline: Token
var line_number: = 1
var col_number = 0
var tab_size = 4

func newline(make_token: bool, add_line: bool = true):
	if make_token and not pending_newline:
		last_newline = make_token(Token.Type.NL, "NL")
		pending_newline = true
	if add_line:
		line_number += 1
		col_number = 0

func skip_comment():
	while current_char != '\n' and current_char != null:
		advance()

func skip_whitespace():
	
	if pending_indents != 0:
		return
	
	var is_line_begin = col_number == 0
	
	if is_line_begin:
		check_indent()
		return
	
	while true:
		match current_char:
			#null:
				#check_indent()
				#newline(true) # add a newline at end of file no matter what
				#break
			" ":
				advance()

			"\t":
				advance()
				col_number += tab_size - 1

			"\n":
				advance()
				newline(!is_line_begin)
				check_indent()

			"#":
				skip_comment()
				advance() # consume \n
				newline(!is_line_begin)
				check_indent()
			_:
				return

func number():
	# Return a (multidigit) integer consumed from the input.
	var result = ''
	var token: Token
	while current_char != null and current_char.is_valid_int():
		result += self.current_char
		self.advance()
	if current_char == '.':
		result += self.current_char
		self.advance()

		while (
			current_char != null and
			current_char.is_valid_int()
		):
			result += current_char
			advance()

		token = make_token(Token.Type.REAL_CONST, float(result))
	else:
		token = make_token(Token.Type.INTEGER_CONST, int(result))
	return token

func name() -> Token:
	var result = ""
	current_char = current_char as String
	var regex = RegEx.new()
	regex.compile(r"\w")
	while current_char != null and regex.search(current_char):
		result += self.current_char
		self.advance()
	
	if not result.is_valid_identifier():
		error("name")
	
	if keywords.has(result):
		return make_token(keywords[result], result)
	
	return make_token(Token.Type.IDENT, result)

func check_indent():
	
	var current_indent_char = current_char #tabs or spaces?
	if is_at_end(): # add missing dedents at end of file
		if indent_level() != 0:
			print("filling ending indents")
		pending_indents -= indent_level()
		indent_stack.clear()
		return
	
	var mixed = false
	var tab_size = 4
	
	while true:
		var indent_count = 0
		while not is_at_end():
			var space = current_char
			if space == '\t':
				# Consider individual tab columns.
				col_number += tab_size - 1
				indent_count += tab_size
			elif space == ' ':
				indent_count += 1
			else:
				break
		
			mixed = mixed or space != current_indent_char;
			advance()
			
		if is_at_end():
			# Reached the end with an empty line, so just dedent as much as needed.
			pending_indents -= indent_level()
			indent_stack.clear()
			return

		var previous_indent = 0
		if current_char == '\n':
			# Empty line, keep going.
			advance();
			newline(false);
			continue;

		if current_char == '#':
			skip_comment()
		
			if is_at_end():
				# Reached the end with an empty line, so just dedent as much as needed.
				pending_indents -= indent_level()
				indent_stack.clear()
				return
			
			advance()
			newline(false)
			continue
		
		if indent_level() > 0:
			previous_indent = indent_stack.back();

		if indent_count == previous_indent:
			# No change in indentation.
			return
		
		if indent_count > previous_indent:
			# Indentation increased.
			indent_stack.push_back(indent_count);
			pending_indents += 1;
		else:
			# Indentation decreased (dedent).
			if indent_level() == 0:
				error("Tokenizer bug: trying to dedent without previous indent.")
				return
			
			while indent_level() > 0 and indent_stack.back() > indent_count:
				indent_stack.pop_back()
				pending_indents -= 1
			if (indent_level() > 0 and indent_stack.back() != indent_count) or (indent_level() == 0 and indent_count != 0):
				# Mismatched indentation alignment.
				error("Unindent doesn't match the previous indentation level.")
				
				# Still, we'll be lenient and keep going, so keep this level in the stack.
				indent_stack.push_back(indent_count)
		break

func indent_level() -> int:
	return len(indent_stack)

func is_at_end():
	return current_char == null
	#return pos >= len(text)

func make_token(token_type: Token.Type,
				value,
				lineno=line_number,
				colno=col_number) -> Token:
	var length = 1
	if value != null:
		length = len(str(value))
	if token_type == Token.Type.TRUE:
		value = true
	if token_type == Token.Type.FALSE:
		value = false
	return Token.new(token_type, value, lineno, colno, length)

func get_next_token():
	
	skip_whitespace()
	
	if pending_newline:
		pending_newline = false
		return last_newline
	
	if pending_indents != 0:
		if pending_indents > 0:
			pending_indents -= 1
			return make_token(Token.Type.BEGIN, "BEGIN")
		else:
			pending_indents += 1
			#newline(true,false)
			return make_token(Token.Type.END, "END")
		
	var result = make_token(Token.Type.EOF, "EOF")
	#print("token starting at {0}".format([current_char]))
	
	while current_char != null:

		if current_char.is_valid_int():
			result = number()
			break
		
		if current_char == "\n":
			advance()
			result = make_token(Token.Type.NL, "\n") #todo: dont create newline if line is empty
			break
		
		if current_char == "\t":
			advance()
			continue
		
		if current_char == ".":
			advance()
			result = make_token(Token.Type.DOT, ".")
			break
		
		if current_char == ':':
			advance()
			result = make_token(Token.Type.COLON, ':')
			break
		
		if current_char == "%":
			advance()
			result = make_token(Token.Type.MOD, '%')
			break
		
		if current_char == '!':
			advance()
			if current_char == "=":
				advance()
				result = make_token(Token.Type.IS_NOT_EQUAL, "!=")
				break
			result = make_token(Token.Type.BANG, '!')
			break
		
		if current_char == "=":
			advance()
			if current_char == "=":
				advance()
				result = make_token(Token.Type.IS_EQUAL, "==")
				break
			result = make_token(Token.Type.ASSIGN, '=')
			break
		
		if current_char == "<":
			advance()
			if current_char == "=":
				advance()
				result = make_token(Token.Type.LT_OR_EQ, "<=")
				break
			result = make_token(Token.Type.LESS_THAN, '<')
			break
		
		if current_char == ">":
			advance()
			if current_char == "=":
				advance()
				result = make_token(Token.Type.GT_OR_EQ, ">=")
				break
			result = make_token(Token.Type.GREATER_THAN, '>')
			break
		
		if current_char == '*':
			advance()
			result = make_token(Token.Type.MUL, '*')
			break
		
		if current_char == '/':
			advance()
			result = make_token(Token.Type.DIV, '/')
			break

		if current_char == '+':
			advance()
			result = make_token(Token.Type.PLUS, '+')
			break
		
		if current_char == '(':
			advance()
			result = make_token(Token.Type.LPAREN, '(')
			break
		
		if current_char == ')':
			advance()
			result = make_token(Token.Type.RPAREN, ')')
			break
		
		if current_char == "[":
			advance()
			result = make_token(Token.Type.LSQUARE, "[")
			break
		
		if current_char == "]":
			advance()
			result = make_token(Token.Type.RSQUARE, "]")
			break

		if current_char == '-':
			advance()
			result = make_token(Token.Type.MINUS, '-')
			break
		
		if current_char == ",":
			advance()
			result = make_token(Token.Type.COMMA, ",")
			break
		
		if current_char == "%":
			advance()
			result = make_token(Token.Type.MOD, "%")
			break
		
		if current_char.is_valid_identifier():
			result = name()
			break
		
		error("get_next_token: {0}".format([current_char]))
		current_char = null
	#print(result)
	return result

func peek(offset: int = 1):
	var peek_pos = self.pos + offset
	if peek_pos > len(self.text) - 1:
		return null
	else:
		return self.text[peek_pos]
