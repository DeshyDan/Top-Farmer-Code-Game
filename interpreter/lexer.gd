class_name Lexer
extends RefCounted

var pos: int
var text: String
var current_char: Variant

var lexer_error: LexerError
var error_pos = 0
var indentation_lvl = -1

var keywords = {
	"var": Token.new(Token.Type.VAR, "VAR")
}
const keyword_data_path = "res://keywords.json"

enum LexerError {
	OK,
	ERROR
}


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
	current_char = self.text[pos]
	lexer_error = LexerError.OK
	#var keyword_data = FileAccess.get_file_as_string(keyword_data_path)
	#keywords = JSON.parse_string(keyword_data)['list']

func reset():
	pos = 0
	current_char = text[pos]
	lexer_error = LexerError.OK

func error(from: String):
	print("parse error at {0}, from {1}".format([pos,from]))
	lexer_error = LexerError.ERROR
	error_pos = pos

func get_error_text() -> String:
	var result = ""
	match lexer_error:
		LexerError.OK:
			result = "no error"
		LexerError.ERROR:
			result = "invalid char at {0}".format([error_pos])
	return result

func advance():
	#"""Advance the 'pos' pointer and set the 'current_char' variable."""
	pos += 1
	if pos > len(text) - 1:
		current_char = null  # Indicates end of input
	else:
		current_char = text[self.pos]

func skip_whitespace():
	while current_char == " " or current_char == "\r":
		advance()
		if current_char == null:
			break

func integer() -> int:
	#"""Return a (multidigit) integer consumed from the input."""
	var result = ''
	while current_char != null and current_char.is_valid_int():
		result += self.current_char
		self.advance()
	return int(result)

func name() -> Token:
	#print("naming")
	var result = ""
	current_char = current_char as String
	var regex = RegEx.new()
	regex.compile(r"\w")
	while regex.search(current_char):
		result += self.current_char
		self.advance()
	
	if not result.is_valid_identifier():
		error("name")
	
	if keywords.has(result):
		return keywords[result]
	
	return Token.new(Token.Type.IDENT, result)

func indent() -> int:
	#print("indenting")
	var result = 0
	current_char = current_char as String
	var regex = RegEx.new()
	regex.compile(r"\t")
	while regex.search(current_char):
		result += 1
		advance()
	return result

func get_next_token():
	#"""Lexical analyzer (also known as scanner or tokenizer)
#
	#This method is responsible for breaking a sentence
	#apart into tokens.
	#"""
	var result = Token.new(Token.Type.EOF, null)
	#print("token starting at {0}".format([current_char]))
	
	while current_char != null:
		var indent_lvl = 0
		if current_char == ' ':
			skip_whitespace()
			#print("finished skipping")
			continue

		if current_char.is_valid_int():
			result = Token.new(Token.Type.INTEGER, integer())
			break
		
		if current_char == "\n":
			advance()
			result = Token.new(Token.Type.NL, "\n")
			break
		
		if current_char == "\t":
			indent_lvl += 1
			advance()
			if peek() != "\t":
				if indent_lvl < indentation_lvl:
					result = Token.new(Token.Type.END,indent_lvl)
					indentation_lvl = indent_lvl
					break
				elif indent_lvl > indentation_lvl:
					result = Token.new(Token.Type.BEGIN,indent_lvl)
					indentation_lvl = indent_lvl
					break
			continue
		
		if current_char == ".":
			advance()
			result = Token.new(Token.Type.DOT, ".")
			break
		
		if current_char == "=":
			advance()
			result = Token.new(Token.Type.ASSIGN, '=')
			break
		
		if current_char == '*':
			advance()
			result = Token.new(Token.Type.MUL, '*')
			break
		
		if current_char == '/':
			advance()
			result = Token.new(Token.Type.DIV, '/')
			break

		if current_char == '+':
			advance()
			result = Token.new(Token.Type.PLUS, '+')
			break
		
		if current_char == '(':
			advance()
			result = Token.new(Token.Type.LPAREN, '(')
			break
		
		if current_char == ')':
			advance()
			result = Token.new(Token.Type.RPAREN, '(')
			break

		if current_char == '-':
			advance()
			result = Token.new(Token.Type.MINUS, '-')
			break
		
		else:
			result = name()
			break

		error("get_next_token: {0}".format([current_char]))
	#print(result)
	return result

func peek():
	var peek_pos = self.pos + 1
	if peek_pos > len(self.text) - 1:
		return null
	else:
		return self.text[peek_pos]
