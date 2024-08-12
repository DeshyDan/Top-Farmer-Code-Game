class_name Program
extends AST

var block: Block

func _init(block: Block):
	self.block = block

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sProgram:\n" % indent_str
	result += block.node_string(indent + 2)
	return result
