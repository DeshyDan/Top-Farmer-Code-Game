extends Control

enum { MAIN_SCREEN, LEVEL_SELECT, LEVEL_PLAY }

@export var main_menu: Node
@export var level_select: Node
@export var menu_cam: Camera2D

var player_save: PlayerSave
var level_scene: PackedScene = preload("res://scenes/level/level.tscn")
var levels_to_load = range(1, 11)

var current_level: Level

func _ready():
	load_save()
	enter_state(MAIN_SCREEN)

func enter_state(state):
	for child in get_children():
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
			if is_instance_valid(current_level) and current_level.is_inside_tree():
				current_level.show()
			else:
				enter_state(MAIN_SCREEN)
		_:
			return

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

	var i = levels_to_load.pop_front()
	load_level(i)

func load_level(i):
	while levels_to_load.pop_front() != i and not levels_to_load.is_empty():
		continue

	var lvl = level_scene.instantiate()

	add_child(lvl)
	current_level = lvl

	var file_path = "res://assets/levels/lvl_" + str(i) + ".txt"
	var goal_harvest = Const.LEVEL_GOALS["level " + str(i)]

	lvl.set_level(file_path, goal_harvest)
	lvl.set_player_save(player_save)
	lvl.set_source_code(player_save.get_level_source(i))
	lvl.id = i
	lvl.level_complete.connect(_on_level_completed)
	lvl.retry_requested.connect(_on_level_retry)
	current_level = lvl

	enter_state(LEVEL_PLAY)

func _on_level_completed():
	current_level.queue_free()
	await get_tree().process_frame
	load_next_level()

func _on_level_retry():
	var to_load = current_level.id
	current_level.queue_free()
	await get_tree().process_frame
	load_level(to_load)

func _on_main_menu_play_button_pressed():
	enter_state(LEVEL_SELECT)

func _on_level_select_level_selected(level):
	print("loading {0}".format([level]))
	load_level(level)
	enter_state(LEVEL_PLAY)
