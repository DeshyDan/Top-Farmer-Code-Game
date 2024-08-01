class_name FunctionDecl
extends AST

var name: Var
var args: Array[VarDecl]
var block: Block

func _init(name: Var, args, block: Block):
	self.name = name
	self.args = args
	self.block = block
