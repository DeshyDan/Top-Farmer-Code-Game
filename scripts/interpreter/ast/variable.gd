class_name Var
extends AST

# AST node representing a variable
# e.g: my_var

var token: Token
var name: String

func _init(token: Token):
	self.token = token
	name = token.value

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sVar: " % indent_str
	result += "%s\n" % name
	return result
