extends Node2D
@onready var window: CodeWindow = $Window


var a = 0
var s: String
func _ready():
	pass

func add(x,y):
	a = 1
	return x + y

func _on_print_requested(arglist):
	print(arglist)
	window.print_to_console("".join(arglist))

func _on_window_run_button_pressed():
	window.reset_console()
	var source = window.get_source_code()
	var lexer = Lexer.new(source)
	#var token = lexer.get_next_token()
	#while token.type != Token.Type.EOF:
		##print(token)
		#token = lexer.get_next_token()
	#lexer.reset()
	var parser = Parser.new(Lexer.new(source))
	var tree = parser.parse()
	if parser.parser_error.error_code:
		window.print_to_console(parser.parser_error.message)
		return
	var interpreter = Interpreter.new(parser)
	interpreter.print_requested.connect(_on_print_requested)
	var sem = SemanticAnalyzer.new()
	sem.visit(tree)
	if sem.semantic_error.error_code:
		window.print_to_console(sem.semantic_error.message)
		window.set_error_line(sem.semantic_error.token.lineno, sem.semantic_error.token.colno)
		return
	interpreter.visit(tree)
	#if interpreter.interpreter_error != Interpreter.InterpreterError.OK:
		#window.print_to_console(interpreter.get_error_text())
		##return
	#interpreter.visit(tree)
	#print(interpreter.variables)
	#interpreter.reset()
	interpreter.print_ast(tree)
