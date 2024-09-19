extends MarginContainer
# Class handles the logic creating routes to level

@export var level_buttons: Node

signal level_selected(level)

func add_level(level):
	var button = Button.new()
	button.text = "Level " + str(level)
	level_buttons.add_child(button)
	button.pressed.connect(_on_level_selected.bind(level))

func reset():
	for node in level_buttons.get_children():
		node.queue_free()

func _on_level_selected(level):
	level_selected.emit(level)
