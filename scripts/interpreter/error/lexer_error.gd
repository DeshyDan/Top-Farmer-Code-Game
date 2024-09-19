class_name LexerError
extends GError

# A lexer error, usually only happens due to 
# an invalid character in the source code string.

func _to_string():
	return "Lexer error"
