class_name Type
extends AST

var token: Token
var type_name: String

func _init(token):
	self.token = token
	type_name = token.value

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sType: " % indent_str
	result += "%s\n" % token.value
	return result