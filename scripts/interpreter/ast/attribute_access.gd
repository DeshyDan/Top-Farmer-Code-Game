class_name AttributeAccess
extends AST

var parent: AST
var member: AST
var token: Token

func _init(parent, token, member):
	self.parent = parent
	self.token = token
	self.member = member
