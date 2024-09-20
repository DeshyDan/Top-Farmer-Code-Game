class_name WhileLoop
extends AST

# AST node representing a while loop

var condition: AST
var block: Block

func _init(condition, block: Block):
	self.condition = condition
	self.block = block

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sWhile:\n" % indent_str
	result += condition.node_string(indent + 2)
	result += block.node_string(indent + 2)
	return result
