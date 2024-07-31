class_name VarDecl
extends AST

var var_node: Var
var type_node: Type

func _init(variable, type):
	var_node = variable
	type_node = type
