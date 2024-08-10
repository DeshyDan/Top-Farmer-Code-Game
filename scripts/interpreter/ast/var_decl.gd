class_name VarDecl
extends AST

var var_node: Var
var type_node: Type
var token: Token

func _init(variable, type):
	var_node = variable
	type_node = type
	token = var_node.token
