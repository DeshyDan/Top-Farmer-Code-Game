class_name PrintCall
extends FunctionCall

# AST node representing a print call
# unused

func _init(args, token: Token):
	self.name = Var.new(Token.new(Token.Type.IDENT, token))
	self.args = args
	self.token = token

func node_string(indent: int):
	var indent_str = " ".repeat(indent)
	var result = "%sPrintCall:\n" % indent_str
	for arg in args:
		result += arg.node_string(indent + 2)
	return result
