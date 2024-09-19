class_name Main
extends Control
# Class acts as a coordinator for navigation between screens.
# It also ensures that users are routed to the correct levels

enum { MAIN_SCREEN, LEVEL_SELECT, LEVEL_PLAY }

@export var main_menu: Node
@export var level_select: Node
@export var menu_cam: Camera2D
@export var level_node: Level
@export var level_loader: LevelLoader

var player_save: PlayerSave
var levels_to_load = range(1, 11)

func _ready():
	menu_cam.make_current()
	load_save()
	enter_state(MAIN_SCREEN)

func enter_state(state):
	for child in get_children():
		if child is CanvasItem:
			child.hide()
	
	match state:
		MAIN_SCREEN:
			menu_cam.make_current()
			main_menu.visible = true
			
		LEVEL_SELECT:
			menu_cam.make_current()
			level_select.visible = true
			levels_to_load = range(1,11)
			show_level_select()
			
		LEVEL_PLAY:
			level_node.show()


func show_level_select():
	level_select.reset()
	for i in levels_to_load:
		level_select.add_level(i)

func load_save():
	player_save = PlayerSave.new()
	player_save.load_progress()

func load_next_level():
	if levels_to_load.is_empty():
		print("All levels loaded")
		enter_state(MAIN_SCREEN)
		return

	var id = levels_to_load.pop_front()
	load_level(id)

func load_level(id):
	levels_to_load = range(id + 1, 11)

	var level_data = level_loader.get_level_data_by_id(id)
	level_node.initialize(level_data)
	enter_state(LEVEL_PLAY)

func _on_main_menu_play_button_pressed():
	enter_state(LEVEL_SELECT)

func _on_level_select_level_selected(level):
	print("loading {0}".format([level]))
	load_level(level)
	enter_state(LEVEL_PLAY)


func _on_level_exit_requested():
	enter_state(LEVEL_SELECT)


func _on_level_victory():
	pass # Replace with function body.


func _on_next_level_requested():
	load_next_level()


func _on_level_retry_requested():
	load_level(level_node.id)
