extends Node2D
@onready var window: CodeWindow = $Window


var a = 0
var s: String
func _ready():
	pass

func add(x,y):
	a = 1
	return x + y


func _on_window_run_button_pressed():
	window.reset_console()
	var source = window.get_source_code()
	var lexer = Lexer.new(source)
	var token = lexer.get_next_token()
	while token.type != Token.Type.EOF:
		print(token)
		token = lexer.get_next_token()
	lexer.reset()
	var parser = Parser.new(lexer)
	var interpreter = Interpreter.new(parser)
	if interpreter.interpreter_error != Interpreter.InterpreterError.OK:
		window.print_to_console(interpreter.get_error_text())
		return
	window.print_to_console(interpreter.visit(parser.parse()))
	print(interpreter.variables)
	interpreter.reset()
	interpreter.print_ast(parser.parse())
