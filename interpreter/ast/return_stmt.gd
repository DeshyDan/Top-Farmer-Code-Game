class_name ReturnStatement
extends AST

var right: AST

func _init(right: AST):
	self.right = right
