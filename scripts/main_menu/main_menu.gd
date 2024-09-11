extends MarginContainer

signal play_button_pressed

func _on_play_button_pressed():
	play_button_pressed.emit()
