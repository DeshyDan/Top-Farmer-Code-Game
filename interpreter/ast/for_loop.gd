class_name ForLoop
extends AST

var identifier
var iterable
var block
var token

func _init(identifier, iterable, block):
	self.identifier = identifier
	self.iterable = iterable
	self.block = block
	token = identifier.token
