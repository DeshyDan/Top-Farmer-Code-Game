class_name BuiltinFuncCall
extends FunctionCall

func _init(name: Var, args, token: Token):
	self.name = name
	self.args = args
	self.token = token
