class_name ArrayNode
extends AST

var items = []

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sArrayDecl: [\n" % indent_str
	for item in items:
		result += item.node_string(indent + 2)
	result += "%s]\n" % indent_str
	return result
