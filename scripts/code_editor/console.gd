class_name Console
extends RichTextLabel

func print_to_player_console(args: Array, color = Color.WHITE):
	var words: PackedStringArray = []
	push_color(color)
	for arg in args:
		words.append(str(arg))
	var line = " ".join(words)
	append_text(line + "\n")
	pop()
