extends Node2D

@onready var level_scene:PackedScene = preload("res://scenes/level/level.tscn")
	
# TODO: change so it will instance a level
# Called when the node enters the scene tree for the first time.
func _ready():
	# Instantiate the loaded scene
	var lvl:Node = level_scene.instantiate()
	# Add the instance to the current scene
	add_child(lvl)
	
	var width:int = 2
	var height:int = 2
	var victory_corn_quantity:int = 4
	
	lvl.set_level(width,height,victory_corn_quantity)
	

	
	

