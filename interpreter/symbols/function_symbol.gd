class_name FunctionSymbol
extends Symbol

var params = []

func _init(name, params=[]):
	super._init(name)
	self.params = params

func _to_string():
	return "<function(name={name},parameters={params})>".format({
		"name":name,
		"params":params
	})
