class_name Boolean
extends AST

# AST node representing a boolean literal:
# e.g. true

var token: Token
var value: bool

func _init(token):
	self.token = token
	self.value = token.value

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = '%sBoolean: ' % indent_str
	result += "{0}\n".format([value])
	return result
