class_name Break
extends AST

# AST node representing a break statement

var token

func _init(_token: Token):
	token = _token
