class_name IndexOp
extends AST

var left: AST
var token: Token
var index: AST

func _init(left, op, index):
	self.left = left
	self.token = op
	self.index = index

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sIndexOp:\n" % indent_str
	result += left.node_string(indent + 1)
	result += index.node_string(indent + 1)
	return result