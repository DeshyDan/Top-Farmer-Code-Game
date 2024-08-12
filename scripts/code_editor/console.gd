class_name Console
extends RichTextLabel

func print_to_player_console(args: Array, source_name, row, column):
	var words: PackedStringArray = []
	for arg in args:
		words.append(str(arg))
	var line = " ".join(words)
	append_text(line + "\n")
	
