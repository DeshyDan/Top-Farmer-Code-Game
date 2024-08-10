class_name UnaryOp
extends AST

var op: Token
var right: AST

func _init(op:Token, right:AST):
	self.op = op
	self.right = right
