extends Node2D

@onready var level_scene:PackedScene = preload("res://scenes/level/level.tscn")
var player_save: PlayerSave

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_save = PlayerSave.new()
	player_save.load_progress()
	
	# Instantiate the loaded scene
	var lvl:Node = level_scene.instantiate()
	# Add the instance to the current scene
	add_child(lvl)
	
	var file_path = "res://assets/levels/lvl3.txt"
	var lvl_skeleton = FileAccess.open(file_path, FileAccess.READ)
	
	var goal_harvest = {
		Const.PlantType.PLANT_CORN: 4,
		Const.PlantType.PLANT_GRAPE: 4
	}
	
	lvl.set_level(lvl_skeleton,goal_harvest)
	lvl.set_player_save(player_save)
	lvl.set_source_code(player_save.get_level_source(3))
