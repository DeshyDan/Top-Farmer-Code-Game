class_name BuiltinSymbol
extends Symbol

func _init(name):
	super._init(name)

func _to_string():
	return "builtin<{0}>".format([name])
