extends Node2D

@onready var level:PackedScene = preload("res://scenes/level/level.tscn")
	
# TODO: change so it will instance a level
# Called when the node enters the scene tree for the first time.
func _ready():
	# Instantiate the loaded scene
	var lvl = level.instantiate()
	# Add the instance to the current scene
	add_child(lvl)
	# size farm, what state is the goal
	#lvl.set_level()
	
	

