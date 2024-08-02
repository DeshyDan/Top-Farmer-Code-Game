class_name FunctionCall
extends AST

var name: Var
var args = []
var token: Token

func _init(name: Var, args, token: Token):
	self.name = name
	self.args = args
	self.token = token
