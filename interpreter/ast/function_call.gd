class_name FunctionCall
extends AST

var name: Var
var args = []

func _init(name: Var, args):
	self.name = name
	self.args = args
