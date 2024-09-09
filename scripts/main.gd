extends Control

enum { MAIN_SCREEN, LEVEL_SELECT, LEVEL_PLAY }

@onready var level_scene:PackedScene = preload("res://scenes/level/level.tscn")
@export var main_menu: Node
@export var level_select: Node
@export var menu_cam: Camera2D

var player_save: PlayerSave

var current_state = MAIN_SCREEN
var current_level: Level

# Called when the node enters the scene tree for the first time.
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
			select_level()
		_:
			return

func load_save():
	player_save = PlayerSave.new()
	player_save.load_progress()

func select_level():
	level_select.reset()
	for unlocked_level in player_save._unlocked_levels:
		level_select.add_level(unlocked_level)

func _on_main_menu_play_button_pressed():
	enter_state(LEVEL_SELECT)

func _on_level_select_level_selected(level):
	enter_state(LEVEL_PLAY)
	var lvl = level_scene.instantiate() as Level
	lvl.position = Vector2(0,0)
	# Add the instance to the current scene
	add_child(lvl)
	
	var file_path = "res://assets/levels/lvl_{0}.txt".format([level])
	
	var goal_harvest = {
		Const.PlantType.PLANT_CORN: 4,
		Const.PlantType.PLANT_GRAPE: 4
	}
	
	lvl.set_level(file_path,goal_harvest)
	lvl.set_player_save(player_save)
	lvl.set_source_code(player_save.get_level_source(3))
	lvl.level_finished.connect(_on_level_finished.bind(level))
	current_level = lvl

func _on_level_finished(level):
	player_save.unlock_level(level + 1)
	enter_state(LEVEL_SELECT)
