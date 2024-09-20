class_name Number
extends AST

# AST node representing a float or int literal

var token: Token
var value

func _init(token):
	self.token = token
	self.value = token.value

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = '%sNumber: ' % indent_str
	result += "%d\n" % value
	return result
