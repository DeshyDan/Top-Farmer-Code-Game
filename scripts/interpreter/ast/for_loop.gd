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

func node_string(indent: int):
  var indent_str = " ".repeat(indent)
  var result = "%sForLoop:\n" % indent_str
  result += "%sIdentifier:\n" % indent_str
  result += identifier.node_string(indent + 2)
  result += "%sIterable:\n" % indent_str
  result += iterable.node_string(indent + 2)
  result += block.node_string(indent + 2)
  return result
