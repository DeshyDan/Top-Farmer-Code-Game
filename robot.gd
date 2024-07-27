class_name Robot
extends Node2D

var visuals = preload("res://robot_visuals.tscn")

func __reset__():
	add_child(visuals.instantiate())

func move(x,y):
	position.x += x
	position.y += y
