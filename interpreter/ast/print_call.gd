class_name PrintCall
extends FunctionCall

func _init(args, token: Token):
	self.name = Var.new(Token.new(Token.Type.IDENT, token))
	self.args = args
	self.token = token
