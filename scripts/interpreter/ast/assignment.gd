class_name Assignment
extends AST

var left: Var
var right: AST
var token: Token

func _init(left: Var, right: AST, token: Token):
	self.left = left
	self.right = right
	self.token = token
