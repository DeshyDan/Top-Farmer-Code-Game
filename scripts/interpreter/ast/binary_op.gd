class_name BinaryOP
extends AST

# AST node representing a binary operation
# e.g. a + 1

var left: AST
var op: Token
var token: Token
var right: AST

func _init(left:AST,op:Token,right:AST):
	self.left = left
	self.token = op
	self.op = op
	self.right = right

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sBinaryOp: %s\n" % [indent_str, op.value]
	result += left.node_string(indent+2)
	result += right.node_string(indent+2)
	return result
