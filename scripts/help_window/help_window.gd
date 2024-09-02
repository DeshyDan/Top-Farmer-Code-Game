extends MarginContainer

@export var help_window_ui: Control
@export var help_button: Control

func _on_help_window_toggle_button_toggled():
	help_window_ui.visible = not help_window_ui.visible
	help_button.visible = not help_button.visible
