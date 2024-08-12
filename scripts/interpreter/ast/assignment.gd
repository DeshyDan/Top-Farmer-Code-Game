class_name Assignment
extends AST

var left: Var
var right: AST
var token: Token

func _init(left: Var, right: AST, token: Token):
	self.left = left
	self.right = right
	self.token = token

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sAssignment:\n" % indent_str
	result += "%sLeft:\n" % indent_str
	result += left.node_string(indent + 2)
	result += "%sRight:\n" % indent_str
	result += right.node_string(indent + 2)
	return result

