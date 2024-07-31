class_name Type
extends AST

var token: Token
var type_name: String

func _init(token):
	self.token = token
	type_name = token.value
