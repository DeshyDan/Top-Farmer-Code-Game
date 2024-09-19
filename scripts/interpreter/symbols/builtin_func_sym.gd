class_name BuiltinFuncSymbol
extends BuiltinSymbol

# Class representing a builtin function symbol
# used during Semantic analysis

var params = []

func _init(name, params):
	super._init(name)
	self.params = params

func _to_string():
	return "builtin<{0}>".format([name])
