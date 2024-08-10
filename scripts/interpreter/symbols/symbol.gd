class_name Symbol
extends RefCounted

var name: String
var type: Symbol

func _init(name, type: Symbol=null):
	self.name = name
	self.type = type
