extends Node
class_name LevelLoader
# Class handles the logic for loading a level from a data source.

var _lvl_array:Array
var _lvl_array_items:Array

var _count = 0
var _original_data : Dictionary
var _level_resources = {}

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
		_level_resources[level_resource.name] = level_resource


func get_level_data_by_name(name: String):
	return _level_resources.get(name)

func get_level_data_by_id(id) -> LevelData:
	for level_resource in _level_resources.values():
		if level_resource.id == id:
			return level_resource
	return null
