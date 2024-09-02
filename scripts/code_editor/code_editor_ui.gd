extends PanelContainer

@onready var player_code_edit = $MarginContainer/VSplitContainer/Robot1
@onready var console = $MarginContainer/VSplitContainer/HBoxContainer/PanelContainer/RichTextLabel

signal run_pressed
signal pause_pressed
signal kill_pressed

func get_code_edit():
	return player_code_edit

func get_console():
	return console

func _on_run_pressed():
	run_pressed.emit()

func _on_pause_pressed():
	pause_pressed.emit()

func _on_kill_pressed():
	kill_pressed.emit()
