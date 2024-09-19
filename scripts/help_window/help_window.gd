extends MarginContainer
# Class handles events emitted in the help window

@export var help_window_ui: Control
@export var help_button: Control

func _ready():
	MessageBus.hint_clicked.connect(_on_hint_clicked)

func _on_help_window_toggle_button_toggled():
	help_window_ui.visible = not help_window_ui.visible
	help_button.visible = not help_button.visible

func _on_hint_clicked(_meta):
	help_window_ui.visible = true
	help_button.visible = false
