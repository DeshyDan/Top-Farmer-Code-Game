class_name CodeWindow
extends Control

var dragging = false
var mouse_in = false
var draggingDistance
var dir
var newPosition = Vector2()
var resizing = false
var mouse_in_resize = false



var code_edit: PlayerEdit
var console: Console

@export var code_editor_ui: Node
@export var hint_popup: Node
@export var resize_panel: Control

@export_multiline var default_text: String

signal run_button_pressed
signal pause_button_pressed
signal kill_button_pressed
signal exec_speed_changed(value)

func _ready():
	code_edit = code_editor_ui.get_code_edit()
	console = code_editor_ui.get_console()
	code_edit.text = default_text

func initialize(level_data: LevelData, source_code: String):
	hint_popup.set_hint_text(level_data.level_hint)
	hint_popup.toggle_popup(true)
	set_source_code(source_code)

func get_source_code() -> String:
	return code_edit.text

func set_source_code(source: String):
	code_edit.cancel_code_completion()
	code_edit.clear()
	code_edit.set_caret_line(0)
	code_edit.set_caret_column(0)
	code_edit.text = source
	code_edit.clear_undo_history()
	reset_console()

func print_to_console(to_print: Variant):
	console.print_to_player_console([to_print])

func highlight_line(lineno: int):
	code_edit.highlight_line.call_deferred(lineno)

func reset_console():
	console.clear()

func set_error(err: GError):
	code_edit.draw_error(err.token.lineno, err.token.colno, err.raw_message)
	
	console.print_to_player_console([err.message], Color.RED * 0.9)

func highlight_tracepoint(node: AST, call_stack: CallStack):
	if node.get("token") == null:
		return
	var lineno = node.token.get("lineno")
	if lineno != null:
		highlight_line(lineno)
	if call_stack.peek().enclosing_ar == null:
		return
	var enclosing_ar = call_stack.peek().enclosing_ar
	var caller_token: Token = call_stack.peek().token
	var func_decl: FunctionDecl = enclosing_ar.get_item(call_stack.peek().name)
	var caller_lineno = caller_token.get("lineno")
	if caller_lineno:
		highlight_line(caller_lineno)
	else:
		print("NO LINENO")
	call_stack.pop()
	# recursively walk up the call stack, highlighting any callers/func decls
	highlight_tracepoint(func_decl, call_stack) 

func _on_run_button_pressed():
	if not code_edit.text.ends_with("\n"):
		# have to do this to avoid bugged errors from code edit node
		code_edit.text += "\n"
		
	run_button_pressed.emit()

func _on_pause_pressed():
	pause_button_pressed.emit()

func _on_kill_pressed():
	kill_button_pressed.emit()


func _on_window_bar_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && mouse_in:
			draggingDistance = position.distance_to(get_viewport().get_mouse_position())
			dir = (get_viewport().get_mouse_position() - position).normalized()
			dragging = true
			newPosition = get_viewport().get_mouse_position() - draggingDistance * dir
		else:
			dragging = false
			
	elif event is InputEventMouseMotion:
		if dragging:
			newPosition = get_viewport().get_mouse_position() - draggingDistance * dir
			position = newPosition

func _on_window_bar_mouse_entered():
	mouse_in = true

func _on_window_bar_mouse_exited():
	mouse_in = false


func _on_panel_mouse_entered():
	mouse_in_resize = true


func _on_panel_mouse_exited():
	mouse_in_resize = false


func _on_panel_gui_input(event):
	
	if event is InputEventMouseButton:
		if event.is_pressed() && mouse_in_resize:
			draggingDistance = position.distance_to(get_viewport().get_mouse_position())
			dir = (get_viewport().get_mouse_position() - position).normalized()
			resizing = true
			newPosition = get_viewport().get_mouse_position() - draggingDistance * dir
		else:
			resizing = false
			
	elif event is InputEventMouseMotion:
		if resizing:
			newPosition = get_viewport().get_mouse_position()
			size = newPosition - position

func _on_exec_speed_slider_value_changed(value):
	exec_speed_changed.emit(value)
