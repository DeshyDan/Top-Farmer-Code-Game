class_name IfStatement
extends AST

var condition: AST
var block: Block

func _init(condition: AST, block: Block):
	self.block = block
	self.condition = condition
