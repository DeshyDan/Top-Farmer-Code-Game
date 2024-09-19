class_name InterpreterClient
extends Node

# This class encapsulates the interpreter and its dependencies
# into a single node that exposes functionality to other in
# game objects. If you want to start an interpreter,
# you call load_source() followed by start(). 

signal finished
signal tracepoint_reached(node: AST, call_stack: CallStack)
signal error(err: GError)

signal print_requested(args: Array)
signal move_requested(args: Array)
signal plant_requested(args: Array)
signal harvest_requested(args: Array)
signal wait_requested(args: Array)

var DEFAULT_BUILTIN_FUNCS = {
	"print": print_call,
	"move": move_call,
	"plant": plant_call,
	"harvest": harvest_call,
	"wait": wait_call
}

var interpreter: Interpreter
# TODO: pass builtins to the lexer, parser, semantic analyser etc.
var builtin_funcs = DEFAULT_BUILTIN_FUNCS
var last_valid_symbol_table: SymbolTable

func _ready():
	MessageBus.code_completion_requested.connect(_on_code_completion_requested)

func load_source(source: String):
	var lexer = Lexer.new(source)
	var parser = Parser.new(lexer)
	var tree = parser.parse()
	if parser.parser_error.error_code:
		show_error(parser.parser_error)
		return false
	var sem = SemanticAnalyzer.new()
	sem.set_builtin_consts(Const.DEFAULT_BUILTIN_CONSTS)
	sem.set_builtin_funcs(DEFAULT_BUILTIN_FUNCS)
	sem.visit(tree)
	if sem.semantic_error.error_code:
		show_error(sem.semantic_error)
		return false
	interpreter = Interpreter.new(tree)
	interpreter.input_mode = true
	interpreter.set_builtin_consts(Const.DEFAULT_BUILTIN_CONSTS)
	interpreter.builtin_func_call.connect(_on_builtin_func_call)
	interpreter.tracepoint.connect(_on_tracepoint_reached)
	interpreter.runtime_error.connect(_on_runtime_error)
	interpreter.finished.connect(_on_interpreter_finished)
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

func kill():
	interpreter = null

func show_error(err: GError):
	error.emit(err)

func print_call(args):
	print_requested.emit(args)
	input.call_deferred(null)

func move_call(args: Array):
	move_requested.emit(args)

func plant_call(args: Array):
	plant_requested.emit(args)

func harvest_call(args: Array):
	harvest_requested.emit(args)

func wait_call(args: Array):
	wait_requested.emit(args)
	input.call_deferred(null)

func _on_interpreter_finished():
	finished.emit()

func _on_runtime_error(err: RuntimeError):
	show_error(err)
	interpreter = null
	finished.emit()

func _on_builtin_func_call(func_name: String, args: Array):
	builtin_funcs[func_name].call(args)

func _on_tracepoint_reached(node: AST, call_stack: CallStack):
	tracepoint_reached.emit(node, call_stack)

func input(data: Variant):
	if not is_instance_valid(interpreter):
		push_error("tried to add interpreter input while interpreter not running")
	interpreter.input.emit(data)
	
func _on_code_completion_requested(source: String):
	var options: Array[CodeCompletionOption] = []
	for builtin_func_name in builtin_funcs.keys():
		options.append(CodeCompletionOption.func_option(builtin_func_name, true))
	for builtin_const_name in Const.DEFAULT_BUILTIN_CONSTS.keys():
		options.append(CodeCompletionOption.const_option(builtin_const_name, true))
		
	var symboltable = last_valid_symbol_table
	
	var lexer = Lexer.new(source)
	
	for keyword in lexer.keywords:
		if keyword == "int":
			# int conflicts with print so skip it
			# TODO: fix this
			continue
		options.append(CodeCompletionOption.keyword_option(keyword))
	MessageBus.set_code_completion_options(options)
	
	# uncomment this when the interpreter is stable enough 
	# to parse on every keystroke
	
	# make a best effort to parse the current program and add player
	# defined symbols to the code completion options, otherwise fall
	# back to last valid symbol table
	
	# TODO: change symbols based on the scope enclosing the caret
	
	#var parser = Parser.new(lexer)
	#var tree = parser.parse()
	#
	#if not parser.parser_error.error_code:
		#var sem = SemanticAnalyzer.new()
		#sem.set_builtin_consts(Const.DEFAULT_BUILTIN_CONSTS)
		#sem.set_builtin_funcs(DEFAULT_BUILTIN_FUNCS)
		#sem.visit(tree)
		#if not sem.semantic_error.error_code:
			#symboltable = sem.current_scope
			#last_valid_symbol_table = symboltable
	#
	#if not symboltable:
		#MessageBus.set_code_completion_options(options)
		#return
	
	#for symbol_name in symboltable._symbols.keys():
		#var symbol = symboltable.lookup(symbol_name)
		#if symbol is FunctionSymbol:
			#options.append(CodeCompletionOption.func_option(symbol_name))
		#if symbol is VarSymbol:
			#options.append(CodeCompletionOption.var_option(symbol_name))
	
