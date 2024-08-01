class_name VarSymbol
extends Symbol

func _init(name, type):
	super._init(name, type)

func _to_string():
	return "<{0}:{1}>".format([name,type])
