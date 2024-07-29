class_name FunctionDecl
extends AST

var name: Token
var args = []
var block: Block

func _init(name: Token, args, block: Block):
	self.name = name
	self.args = args
	self.block = block
