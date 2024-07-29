extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var regex = RegEx.new()
	var error = regex.compile(r'[ \r\f\v]')
	var text = "a = 2"
	if error != Error.OK:
		print("regex error")
		return
	var pos = 0
	var result = regex.search(text, pos)
	var skip_n = 1
	for n in range(pos, pos + result.get_start()):
		skip_n += 1
		print("skipping")
	print(text[skip_n + pos])
