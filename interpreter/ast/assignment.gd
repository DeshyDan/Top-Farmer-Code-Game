class_name Assignment
extends AST

var left: Var
var right: AST

func _init(left: Var, right: AST):
	self.left = left
	self.right = right
