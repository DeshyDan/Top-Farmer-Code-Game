extends Control

enum { MAIN_SCREEN, LEVEL_SELECT, LEVEL_PLAY }

@export var main_menu: Node
@export var level_select: Node
@export var menu_cam: Camera2D

var player_save: PlayerSave
var level_scene: PackedScene
var levels_to_load = range(1, 4)

var current_level: Level
func _ready():
	load_save()
	enter_state(MAIN_SCREEN)

func enter_state(state):
	for child in get_children():
		child.hide()
	if is_instance_valid(current_level) and current_level.is_inside_tree():
		current_level.queue_free()
	match state:
		MAIN_SCREEN:
			menu_cam.make_current()
			main_menu.visible = true
		LEVEL_SELECT:
			menu_cam.make_current()
			level_select.visible = true
			#select_level()
		_:
			return

func load_save():
	player_save = PlayerSave.new()
	level_scene = preload("res://scenes/level/level.tscn")
	#iterate throgh text file and create a dictionary of the level gaols and use the key to store the goal inside
	load_next_level()

func load_next_level():
	player_save.load_progress()
	
	if levels_to_load.is_empty():
		print("All levels loaded")
		return

	var i = levels_to_load.pop_front()
	var lvl = level_scene.instantiate()
	lvl.position = Vector2(0, 0)
	add_child(lvl)
	current_level = lvl

	var file_path = "res://assets/levels/lvl_" + str(i) + ".txt"
	var goal_harvest = Const.LEVEL_GOALS["level " + str(i)]

	lvl.set_level(file_path, goal_harvest)
	lvl.set_player_save(player_save)
	lvl.set_source_code(player_save.get_level_source(3))
	lvl.level_finished.connect(_on_level_exited.bind(i))
	current_level = lvl

	lvl.connect("level_complete", Callable(self, "_on_level_completed"))

func _on_level_completed():
	current_level.queue_free()
	await get_tree().process_frame
	load_next_level()

func _on_level_exited(level):
	player_save.unlock_level(level + 1)
	enter_state(LEVEL_SELECT)


func _on_main_menu_play_button_pressed():
	enter_state(LEVEL_SELECT)


func _on_level_select_level_selected(level):
	enter_state(LEVEL_PLAY)
