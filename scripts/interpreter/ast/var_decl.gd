class_name VarDecl
extends AST

# AST node representing a variable declaration
# statement, e.g: var x:int

var var_node: Var
var type_node: Type
var token: Token

func _init(variable, type):
	var_node = variable
	type_node = type
	token = var_node.token

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sVarDecl:\n" % indent_str
	result += var_node.node_string(indent + 2)
	result += type_node.node_string(indent + 2)
	return result
