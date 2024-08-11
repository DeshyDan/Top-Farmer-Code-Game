class_name AttributeAccess
extends AST

var parent: AST
var member: AST
var token: Token

func _init(parent, token, member):
	self.parent = parent
	self.token = token
	self.member = member

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sAttributeAccess:\n" % indent_str
	result += parent.node_string(indent + 2)
	result += member.node_string(indent + 2)
	return result
