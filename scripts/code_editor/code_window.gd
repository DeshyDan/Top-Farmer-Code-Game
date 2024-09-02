class_name CodeWindow
extends Window

@export var code_edit: PlayerEdit
@export var console: Console
@export_multiline var default_text: String :
	get:
		return default_text
	set(value):
		default_text = value
		code_edit.text = default_text

signal run_button_pressed
signal pause_button_pressed
signal kill_button_pressed

func _ready():
	MessageBus.code_completion_set.connect(_on_code_completion_set)

func get_source_code() -> String:
	return code_edit.text

func print_to_console(to_print: Variant):
	console.print_to_player_console([to_print],null, null, null)

func highlight_line(lineno: int):
	#print("window got lineno: %d" % lineno)
	code_edit.highlight_line.call_deferred(lineno)

func reset_console():
	console.text = ""
	code_edit.clear_executing_lines()

func set_error_line(lineno, colno):
	code_edit.set_caret_line(lineno -1)
	code_edit.set_caret_column(colno)
	code_edit.set_code_hint("Error")
	code_edit.set_code_hint_draw_below(true)
	code_edit.clear_executing_lines()
	if lineno < code_edit.get_line_count():
		code_edit.set_line_as_executing(lineno, true)

func highlight_tracepoint(node: AST, call_stack: CallStack):
	if node.get("token") == null:
		return
	var lineno = node.token.get("lineno")
	if lineno != null:
		highlight_line(lineno -1)
	if call_stack.peek().enclosing_ar == null:
		return
	var enclosing_ar = call_stack.peek().enclosing_ar
	var caller_token: Token = call_stack.peek().token
	var func_decl: FunctionDecl = enclosing_ar.get_item(call_stack.peek().name)
	var caller_lineno = caller_token.get("lineno")
	if caller_lineno:
		highlight_line(caller_lineno - 1)
	else:
		print("NO LINENO")
	call_stack.pop()
	# recursively walk up the call stack, highlighting any callers/func decls
	highlight_tracepoint(func_decl, call_stack) 

func _on_run_button_pressed():
	run_button_pressed.emit()

func _on_pause_pressed():
	pause_button_pressed.emit()

func _on_kill_pressed():
	kill_button_pressed.emit()

func _on_code_edit_code_completion_requested():
	MessageBus.request_code_completion(code_edit.text)

func _on_code_completion_set(options: Array[CodeCompletionOption]):
	for option in options:
		code_edit.add_code_completion_option(
			option.kind,
			option.display,
			option.replacement, 
			Color.WHITE, null, 0)
	code_edit.update_code_completion_options(false)
