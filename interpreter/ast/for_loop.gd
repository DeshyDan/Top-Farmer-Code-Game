class_name ForLoop
extends AST

var identifier
var iterable
var block

func _init(identifier, iterable, block):
	self.identifer = identifier
	self.iterable = iterable
	self.block = block
