class_name Lexer
extends RefCounted

var pos: int
var text: String
var current_char: Variant

var lexer_error: LexerError
var error_pos = 0

var indent_stack = []
var pending_indents = 0

var keywords = {
	"var": Token.Type.VAR,
	"func": Token.Type.FUNC
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
	pending_newline = false
	line_number = 0
	col_number = 0
	tab_size = 4
	pending_indents = 0

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
	col_number += 1
	if pos > len(text) - 1:
		current_char = null  # Indicates end of input
		newline(true) # add newline at end of input no matter what
		check_indent()
	else:
		current_char = text[self.pos]

var pending_newline = false
var last_newline: Token
var line_number: = 0
var col_number = 0
var tab_size = 4

func newline(make_token: bool):
	if make_token:
		last_newline = Token.new(Token.Type.NL, null)
		pending_newline = true
	line_number += 1
	col_number = 0

func skip_whitespace():
	if pending_indents != 0:
		return
	
	var is_line_begin = col_number == 0
	
	if is_line_begin:
		check_indent()
		return
	
	while true:
		match current_char:
			null:
				pass
			" ":
				advance()

			"\t":
				advance()
				col_number += tab_size - 1

			"\n":
				advance()
				newline(!is_line_begin)
				check_indent()

			_:
				return

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
	while current_char != null and regex.search(current_char):
		result += self.current_char
		self.advance()
	
	if not result.is_valid_identifier():
		error("name")
	
	if keywords.has(result):
		return Token.new(keywords[result], result)
	
	return Token.new(Token.Type.IDENT, result)

func check_indent():
	#print("indenting")
	var indent_count = 0
	var current_indent_char = current_char #tabs or spaces?
	if is_at_end(): # add missing dedents at end of file
		if indent_level() != 0:
			print("filling ending indents")
		pending_indents -= indent_level()
		indent_stack.clear()
		return
	
	var mixed = false
	var tab_size = 4
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
	

	
	while true:
		var previous_indent = 0
		if current_char == '\n':
			# Empty line, keep going.
			advance();
			newline(false);
			continue;
		
		if is_at_end():
			# Reached the end with an empty line, so just dedent as much as needed.
			pending_indents -= indent_level()
			indent_stack.clear()
			return
		
		
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
				#Token error = make_error("Unindent doesn't match the previous indentation level.");
				#error.start_line = line;
				#error.start_column = 1;
				#error.leftmost_column = 1;
				#error.end_column = column + 1;
				#error.rightmost_column = column + 1;
				#push_error(error);
				# Still, we'll be lenient and keep going, so keep this level in the stack.
				indent_stack.push_back(indent_count)
		break

func indent_level() -> int:
	return len(indent_stack)

func is_at_end():
	return current_char == null
	#return pos >= len(text)

func get_next_token():
	#"""Lexical analyzer (also known as scanner or tokenizer)
#
	#This method is responsible for breaking a sentence
	#apart into tokens.
	#"""
	skip_whitespace()
	
	if pending_newline:
		pending_newline = false
		return last_newline
	
	if pending_indents != 0:
		if pending_indents > 0:
			pending_indents -= 1
			return Token.new(Token.Type.BEGIN, null)
		else:
			pending_indents += 1
			return Token.new(Token.Type.END, null)
		
	var result = Token.new(Token.Type.EOF, null)
	#print("token starting at {0}".format([current_char]))
	
	while current_char != null:

		if current_char.is_valid_int():
			result = Token.new(Token.Type.INTEGER, integer())
			break
		
		if current_char == "\n":
			advance()
			result = Token.new(Token.Type.NL, "\n") #todo: dont create newling if line is empty
			break
		
		if current_char == "\t":
			advance()
			# TODO
			continue
		
		if current_char == ".":
			advance()
			result = Token.new(Token.Type.DOT, ".")
			break
		
		if current_char == ':':
			advance()
			result = Token.new(Token.Type.COLON, ':')
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

func peek(offset: int = 1):
	var peek_pos = self.pos + offset
	if peek_pos > len(self.text) - 1:
		return null
	else:
		return self.text[peek_pos]
