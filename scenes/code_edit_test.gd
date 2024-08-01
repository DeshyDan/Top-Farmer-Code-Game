class_name CodeWindow
extends Window

@export var code_edit: CodeEdit
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

func get_source_code() -> String:
	return code_edit.text

func print_to_console(to_print: Variant):
	console.print_to_player_console([to_print],null, null, null)

func reset_console():
	console.text = ""
	code_edit.clear_executing_lines()

func set_error_line(lineno, colno):
	code_edit.set_caret_line(lineno -1)
	code_edit.set_caret_column(colno)
	code_edit.set_code_hint("Error")
	code_edit.set_code_hint_draw_below(true)
	code_edit.clear_executing_lines()
	code_edit.set_line_as_executing(lineno, true)

func _on_run_button_pressed():
	run_button_pressed.emit()


func _on_pause_pressed():
	pause_button_pressed.emit()


func _on_kill_pressed():
	kill_button_pressed.emit()
