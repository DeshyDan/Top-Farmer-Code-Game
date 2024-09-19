class_name UnaryOp
extends AST

# AST node representing an unary operation
# e.g: -1

var op: Token
var right: AST

func _init(op:Token, right:AST):
	self.op = op
	self.right = right

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sUnaryOp: " % indent_str
	result += "%s\n" % op.value
	result += right.node_string(indent + 2)
	return result
