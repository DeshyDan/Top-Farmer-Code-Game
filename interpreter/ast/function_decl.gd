class_name FunctionDecl
extends AST

var name: Var
var args = []
var block: Block

func _init(name: Var, args, block: Block):
	self.name = name
	self.args = args
	self.block = block
