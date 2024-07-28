class_name Robot
extends Node2D

var visuals = preload("res://scenes/robot_visuals.tscn")

enum Direction {
	North,
	South,
	East,
	West
}

enum State {
	Moving,
	Harvesting,
	Idle
}

var state = State.Idle

func __reset__():
	add_child(visuals.instantiate())

signal move_requested(direction: Direction)

func plant(pos: Vector2i):
	MessageBus.robot_plant_requested.emit(pos)

func move(direction: Direction):
	if state != State.Idle:
		return
	move_requested.emit(direction)
