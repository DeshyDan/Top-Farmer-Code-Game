extends VBoxContainer

@export var hint_page: Control
@export var hint_text: RichTextLabel

func set_hint_text(text: String):
	hint_text.clear()
	hint_text.append_text(text)

func _ready():
	hint_text.meta_clicked.connect(MessageBus.request_hint_click)

func _on_hint_button_toggled(toggled_on):
	hint_page.visible = toggled_on
