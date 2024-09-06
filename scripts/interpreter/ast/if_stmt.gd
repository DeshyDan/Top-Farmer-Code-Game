class_name IfStatement
extends AST

var condition: AST
var block: Block
var else_block: Block

func _init(condition: AST, block: Block, else_block: Block):
	self.block = block
	self.condition = condition
	self.else_block = else_block

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sIfStatement:\n" % indent_str
	result += condition.node_string(indent + 2)
	result += block.node_string(indent + 2)
	result += else_block.node_string(indent + 2)
	return result
