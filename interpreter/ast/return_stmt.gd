class_name ReturnStatement
extends AST

var token: Token
var right: AST

func _init(right: AST, token: Token):
	self.right = right
	self.token = token
