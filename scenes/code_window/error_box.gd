extends HBoxContainer

@export var label: RichTextLabel

func set_text(text: String):
	label.text = ""
	label.clear()
	label.append_text(text)
