extends VBoxContainer
# Class allows the user to view hints related a level

@export var hint_page: Control
@export var hint_text: RichTextLabel
@export var hint_button: CheckButton

func _ready():
	hint_text.meta_clicked.connect(MessageBus.request_hint_click)

func toggle_popup(value: bool):
	hint_page.visible = value
	hint_button.button_pressed = value

func set_hint_text(text: String):
	hint_text.clear()
	hint_text.append_text(text)

func _on_hint_button_toggled(toggled_on):
	hint_page.visible = toggled_on
