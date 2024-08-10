class_name WhileLoop
extends AST

var condition: AST
var block: Block

func _init(condition, block: Block):
	self.condition = condition
	self.block = block

