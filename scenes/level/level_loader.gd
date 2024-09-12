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
	for level_resource in level_resources.values():
		if level_resource.name == name:
			return level_resource
	return null

func get_level_data_by_id(id):
	for level_resource in level_resources.values():
		if level_resource.id == id:
			return level_resource

func get_level_by_name(name: String):
	var lvl_data = get_level_data_by_name(name)
	
	if lvl_data == null:
		return null

	if lvl_data.farm_string == "":
		return null

	var lines = lvl_data.farm_string.split("\n")
	var height = 0
	var width = 0
	
	for line in lines:
		if line.strip_edges() != "":
			var items = line.split(",")
			if items.size() == 0:
				return null
			lvl_array.append(items)
			width = max(width, len(items))
			height += 1
	
	for i in range(lvl_array.size()):
		if not lvl_array[i].size() == width:
			return null
	
	if height == 0 or width == 0:
		return null

	# Rest of the function remains the same
	var default_value = null
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(default_value)
		lvl_array_items.append(row)
	
	for i in range(0, height):
		for j in range(0, width):
			var item = lvl_array[i][j]
			var coord: Vector2i = Vector2i(j, i)
			if item == "#":
				lvl_array_items[i][j] = null
			elif item == "r":
				var rock = Obstacle.ROCK()
				lvl_array_items[i][j] = rock
			elif item == "s":
				var rock = Obstacle.ROCK()
				rock.set_translucent(true)
				lvl_array_items[i][j] = rock
			elif item == "w":
				if i == 0 or i == (height-1) or j == (width-1) or j == 0:
					return null
				var water = Obstacle.WATER()
				lvl_array_items[i][j] = water
			elif item == "l":
				if i == 0 or i == (height-1) or j == (width-1) or j == 0:
					return null
				var water = Obstacle.WATER()
				water.set_translucent(true)
				lvl_array_items[i][j] = water
			elif item == "g":
				var goal = Goal.GOAL()
				lvl_array_items[i][j] = goal
			
	var data = {
		"FarmArray": lvl_array_items,
		"width": width,
		"height": height
	}
	
	var farm_model = _create_farm_model(data)
	
	var player_save = PlayerSave.new()
	player_save.load_progress()
	
	var level_scene: PackedScene = preload("res://scenes/level/level.tscn")
	var lvl = level_scene.instantiate()
	
	var goal_harvest = {
		Const.PlantType.PLANT_CORN: lvl_data.corn_goal,
		Const.PlantType.PLANT_GRAPE: lvl_data.grape_goal
	}
	
	lvl.set_level(farm_model,goal_harvest)
	lvl.set_player_save(player_save)
	lvl.set_source_code(player_save.get_level_source(lvl_data.id))
	lvl.id = lvl_data.id
	
	return lvl
	
	
	
	


func _create_farm_model(data:Dictionary):

	var farm_model = FarmModel.new(data["width"],data["height"])
	var array = data["FarmArray"]
	
	for i in range(0,data["height"]):
		for j in range(0,data["width"]):
			var item = array[i][j]
			var coord: Vector2i = Vector2i(j, i)
			if item == null:
				continue
			else:
				farm_model.add_farm_item(item,coord)
	
	return farm_model
