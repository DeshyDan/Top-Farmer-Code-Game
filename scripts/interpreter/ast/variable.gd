class_name Var
extends AST

var token: Token
var name: String

func _init(token: Token):
	self.token = token
	name = token.value
