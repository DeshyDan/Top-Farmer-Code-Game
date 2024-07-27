
extends Node

signal print_requested(args, source_name, row, column)

func print_log(args, source_name, row, column):
	print_requested.emit(args,source_name,row,column)
	for arg in args:
		prints(arg)
