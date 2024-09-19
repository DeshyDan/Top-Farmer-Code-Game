class_name BuiltinFuncCall
extends FunctionCall

# AST node representing a builtin function call
# unused currently

func _init(name: Var, args, token: Token):
	self.name = name
	self.args = args
	self.token = token
