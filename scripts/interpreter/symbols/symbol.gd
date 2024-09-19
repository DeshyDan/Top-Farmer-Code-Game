class_name Symbol
extends RefCounted

# Base class for symbols used during semantic 
# analysis. A symbol corresponds to a variable,
# function or type.

var name: String
var type: Symbol

func _init(name, type: Symbol=null):
	self.name = name
	self.type = type
