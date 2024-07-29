class_name Token

extends RefCounted

enum Type {
	INTEGER,
	PLUS,
	MINUS,
	EOF
}

const TYPE_STRINGS =  {
	Type.INTEGER: "INTEGER",
	Type.PLUS: "PLUS",
	Type.MINUS: "MINUS",
	Type.EOF: "EOF"
}

var type
var value

func _init(type: Type, value: String):
	self.type = type
	self.value = value

func _to_string() -> String:
	return "Token ({0},{1})".format([TYPE_STRINGS[type], value])
	
