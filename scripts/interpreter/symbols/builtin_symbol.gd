class_name BuiltinSymbol
extends Symbol

# Class representing a builtin symbol
# used for builtin constants and types

func _init(name):
	super._init(name)

func _to_string():
	return "builtin<{0}>".format([name])
