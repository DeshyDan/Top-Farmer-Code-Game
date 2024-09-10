extends Node

var player_save: PlayerSave
var level_scene: PackedScene
var current_level: Node
var levels_to_load = range(1, 4)

func _ready():
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
	var goal_harvest = {
		Const.PlantType.PLANT_CORN:Const.LEVEL_GOALS["level "+str(i)]["corn"],
		Const.PlantType.PLANT_GRAPE:  Const.LEVEL_GOALS["level "+str(i)]["grape"]
	}

	lvl.set_level(file_path, goal_harvest)
	lvl.set_player_save(player_save)
	lvl.set_source_code(player_save.get_level_source(3))

	lvl.connect("level_complete", Callable(self, "_on_level_completed"))

func _on_level_completed():
	current_level.queue_free()
	await get_tree().process_frame
	load_next_level()
