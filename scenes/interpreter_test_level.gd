extends Node2D
@onready var window: CodeWindow = $Window
@onready var robot = $Robot

func _on_print_requested(arglist):
	print(arglist)
	window.print_to_console("".join(arglist))

func _on_move_requested(move: int):
	robot.move.call_deferred(move)

func _on_tracepoint_reached(node: AST, call_stack: CallStack):
	if node.get("token") == null:
		return
	var lineno = node.token.get("lineno")
	if lineno != null:
		window.highlight_line(lineno -1)
	if call_stack.peek().enclosing_ar == null:
		return
	var enclosing_ar = call_stack.peek().enclosing_ar
	var caller_token: Token = call_stack.peek().token
	var func_decl: FunctionDecl = enclosing_ar.get_item(call_stack.peek().name)
	var caller_lineno = caller_token.get("lineno")
	if caller_lineno:
		#print("highlighting caller on line %d" % caller_lineno)
		window.highlight_line(caller_lineno - 1)
	else:
		print("NO LINENO")
	call_stack.pop()
	_on_tracepoint_reached(func_decl, call_stack) # recursively walk up the call stack, highlighting any callers/func decls


var thread: Thread
var interpreter: Interpreter
var mutex: Mutex
var timer: Timer

@export var tick_rate = 4

func _on_window_run_button_pressed():
	thread = Thread.new()
	mutex = Mutex.new()
	thread.start(interpreter_thread)
	var tick_length = 1.0/float(tick_rate)
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_tick)
	timer.start(tick_length)

func interpreter_thread():
	window.reset_console.call_deferred()
	var source = window.get_source_code()
	var lexer = Lexer.new(source)
	var token = lexer.get_next_token()
	while token.type != Token.Type.EOF:
		print(token)
		token = lexer.get_next_token()
	lexer.reset()
	var parser = Parser.new(Lexer.new(source))
	var tree = parser.parse()
	if parser.parser_error.error_code:
		window.print_to_console(parser.parser_error.message)
		return
	interpreter = Interpreter.new(parser)
	interpreter.print_requested.connect(_on_print_requested)
	interpreter.move_requested.connect(_on_move_requested)
	interpreter.tracepoint.connect(_on_tracepoint_reached)
	var sem = SemanticAnalyzer.new()
	sem.visit(tree)
	interpreter.print_ast(tree)
	if sem.semantic_error.error_code:
		window.print_to_console(sem.semantic_error.message)
		window.set_error_line(sem.semantic_error.token.lineno, sem.semantic_error.token.colno)
		return
	await interpreter.visit(tree)
	remove_child.call_deferred(timer) # todo: fix so spamming run button doesnt spawn new timers

func _on_window_pause_button_pressed():
	mutex.lock()
	if not interpreter:
		return
	interpreter.tick.emit()
	mutex.unlock()

func _on_timer_tick():
	mutex.lock()
	if not interpreter:
		return
	interpreter.tick.emit()
	mutex.unlock()
