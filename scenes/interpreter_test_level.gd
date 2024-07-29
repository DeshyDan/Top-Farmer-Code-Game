extends Node2D

func _ready():
	var token = Token.new(Token.Type.INTEGER, "1")
	print(token)
