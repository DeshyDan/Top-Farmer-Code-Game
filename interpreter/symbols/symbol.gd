class_name Symbol
extends RefCounted

var name: String
var type: Variant

func _init(name,type=null):
	self.name = name
	self.type = type
