extends Node
class_name LevelLoader

var lvl_array:Array
var lvl_array_items:Array

var count = 0
var original_data : Dictionary
var level_resources = {}

static var level_dir = "res://assets/levels/"

func _init():
	var dir = DirAccess.open(level_dir)
	if not dir:
		return
	var file_paths = dir.get_files()
	
	for file_name in file_paths:
		# On macos files are remapped for some reason
		# https://forum.godotengine.org/t/error-loading-resource-files-in-game-build-in-godot-4/1392
		file_name = file_name.trim_suffix(".remap")
		
		if not file_name.ends_with(".tres"):
			continue
		var level_resource = load(level_dir + file_name)
		level_resources[level_resource.name] = level_resource
		
	print(level_resources)

func get_level_data_by_name(name: String):
	return level_resources.get(name)

func get_level_data_by_id(id):
	for level_resource in level_resources.values():
		if level_resource.id == id:
			return level_resource
