class_name InterpreterClient
extends Node

signal finished
signal tracepoint_reached(node: AST, call_stack: CallStack)
signal error(message: String)
signal print_requested(args: Array)
signal move_requested(args: Array)
signal plant_requested(args: Array)
signal harvest_requested(args: Array)

var DEFAULT_BUILTIN_FUNCS = {
	"print": print_call,
	"move": move_call,
	"plant": plant_call,
	"harvest": harvest_call
}

var interpreter: Interpreter
# TODO: pass builtins to the lexer, parser, semantic analyser etc.
var builtin_funcs = DEFAULT_BUILTIN_FUNCS

func load_source(source: String):
	var lexer = Lexer.new(source)
	if lexer.lexer_error:
		show_error(lexer.get_error_text())
		return false
	var parser = Parser.new(lexer)
	var tree = parser.parse()
	if parser.parser_error.error_code:
		show_error(parser.parser_error.message)
		return false
	var sem = SemanticAnalyzer.new()
	sem.visit(tree)
	if sem.semantic_error.error_code:
		show_error(sem.semantic_error.message)
		#window.set_error_line(sem.semantic_error.token.lineno, sem.semantic_error.token.colno)
		return false
	interpreter = Interpreter.new(tree)
	interpreter.builtin_func_call.connect(_on_builtin_func_call)
	interpreter.tracepoint.connect(_on_tracepoint_reached)
	return true

func start():
	if not interpreter:
		push_error("interpreter started before parsing")
	interpreter.start()
	print("interpreter started")

func tick():
	if not interpreter:
		return
	interpreter.tick.emit()

func show_error(message: String):
	error.emit(message)

func print_call(args):
	print_requested.emit(args)

func move_call(args: Array):
	move_requested.emit(args)

func plant_call(args: Array):
	plant_requested.emit(args)

func harvest_call(args: Array):
	harvest_requested.emit(args)

func _on_builtin_func_call(func_name: String, args: Array):
	builtin_funcs[func_name].call(args)

func _on_tracepoint_reached(node: AST, call_stack: CallStack):
	tracepoint_reached.emit(node, call_stack)
