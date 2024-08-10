
extends Node

signal print_requested(args, source_name, row, column)

signal robot_plant_requested(pos: Vector2i)

func print_log(args, source_name, row, column):
	print_requested.emit(args,source_name,row,column)
	for arg in args:
		prints(arg)
