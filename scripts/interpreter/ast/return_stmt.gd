class_name ReturnStatement
extends AST

var token: Token
var right: AST

func _init(right: AST, token: Token):
  self.right = right
  self.token = token

func node_string(indent: int):
  var indent_str = " ".repeat(indent)
  var result = "%sReturnStatement:\n" % indent_str
  result += right.node_string(indent + 2)
  return result
