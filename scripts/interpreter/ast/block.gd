class_name Block
extends AST

# AST node representing a list of sequential statements

var children = []

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sBlock:\n" % indent_str
	for child in children:
		result += child.node_string(indent + 2)
	return result

