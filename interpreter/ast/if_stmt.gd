class_name IfStatement
extends AST

var condition: AST
var block: Block
var else_block: Block

func _init(condition: AST, block: Block, else_block: Block):
	self.block = block
	self.condition = condition
	self.else_block = else_block
