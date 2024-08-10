class_name IndexOp
extends AST

var left: AST
var token: Token
var index: AST

func _init(left, op, index):
	self.left = left
	self.token = op
	self.index = index
