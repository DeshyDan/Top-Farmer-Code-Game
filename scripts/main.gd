extends Node2D

@onready var level_scene:PackedScene = preload("res://scenes/level/level.tscn")
var player_save: PlayerSave

# Called when the node enters the scene tree for the first time.
func _ready():
	player_save = PlayerSave.new()
	player_save.load_progress()
	
	# Instantiate the loaded scene
	var lvl:Node = level_scene.instantiate()
	lvl.position = Vector2(0,0)
	# Add the instance to the current scene
	add_child(lvl)
	
	#needed to add noide to differentiate from tests and gane play, 1 is more more testing farm_view
	var mode = 0
	
	var level = 5
	
	var goal_harvest = {
		Const.PlantType.PLANT_CORN: 4,
		Const.PlantType.PLANT_GRAPE: 4
	}
	
	lvl.set_level(goal_harvest,level,0)
	lvl.set_player_save(player_save)
	lvl.set_source_code(player_save.get_level_source(3))
