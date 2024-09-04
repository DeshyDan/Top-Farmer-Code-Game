extends Node2D

@onready var level_scene:PackedScene = preload("res://scenes/level/level.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Instantiate the loaded scene
	var lvl:Node = level_scene.instantiate()
	lvl.position = Vector2(0,0)
	# Add the instance to the current scene
	add_child(lvl)
	
	var level = 3
	
	var file_path = "res://assets/levels/lvl_" + str(level) + ".txt"
	var lvl_skeleton = FileAccess.open(file_path, FileAccess.READ)
	
	var goal_harvest = {
		Const.PlantType.PLANT_CORN: 4,
		Const.PlantType.PLANT_GRAPE: 4
	}
	
	lvl.set_level(lvl_skeleton,goal_harvest,level)
