class_name FunctionCall
extends AST

var name: Var
var args = []
var token: Token

func _init(name: Var, args, token: Token):
	self.name = name
	self.args = args
	self.token = token

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sFunctionCall:\n" % indent_str
	result += name.node_string(indent + 2)
	for arg in args:
		result += arg.node_string(indent + 2)
	return result
