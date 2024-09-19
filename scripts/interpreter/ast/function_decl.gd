class_name FunctionDecl
extends AST

# AST node representing a function declaration

var name: Var
var args: Array[VarDecl]
var block: Block
var token: Token

func _init(name: Var, args, block: Block):
	self.name = name
	self.args = args
	self.block = block
	token = name.token

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sFunctionDecl: " % indent_str
	result += "%s\n" % name.name
	for arg in args:
		result += arg.node_string(indent + 2)
	result += block.node_string(indent + 2)
	return result
