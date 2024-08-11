class_name AST
extends RefCounted

func _to_string():
	return node_string(0)

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	return "%sBase Node: Print not implemented for this type\n" % indent_str
