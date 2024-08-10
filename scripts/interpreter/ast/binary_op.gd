class_name BinaryOP
extends AST

var left: AST
var op: Token
var token: Token
var right: AST

func _init(left:AST,op:Token,right:AST):
	self.left = left
	self.token = op
	self.op = op
	self.right = right
