extends Control
@export var help_text: RichTextLabel

func _on_help_contents_item_selected(help_item: HelpItem):
	help_text.clear()
	help_text.append_text("[b]%s[/b]\n\n" % help_item.title)
	help_text.append_text(help_item.content)
