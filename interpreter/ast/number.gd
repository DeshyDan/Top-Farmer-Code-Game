class_name Number
extends AST

var token: Token
var value

func _init(token):
	self.token = token
	self.value = token.value
