extends MarginContainer

@export var help_window_ui: Control

func _on_help_window_toggle_button_toggled(toggled_on):
	help_window_ui.visible = toggled_on
