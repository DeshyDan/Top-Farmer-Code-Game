extends Node2D

@onready var farm = $Farm

func _ready():
	MessageBus.robot_move_requested.connect(_on_robot_move_requested)
	MessageBus.robot_plant_requested.connect(_on_robot_plant_requested)

func _on_robot_move_requested(dir: Robot.Direction):
	pass

func _on_robot_plant_requested(pos: Vector2i):
	farm.plant(Farm.Plant.Carrot, pos)
