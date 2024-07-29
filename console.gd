class_name Console
extends RichTextLabel

func _ready():
	MessageBus.print_requested.connect(print_to_player_console)

func print_to_player_console(args: Array, source_name, row, column):
	var words: PackedStringArray = []
	for arg in args:
		words.append(str(arg))
	var line = " ".join(words)
	text += line
	text += "\n"
	
