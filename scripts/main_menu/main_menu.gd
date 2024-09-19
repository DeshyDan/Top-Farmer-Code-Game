extends MarginContainer
# Class handles events emitted from MainMenu component

signal play_button_pressed

func _on_play_button_pressed():
	play_button_pressed.emit()
