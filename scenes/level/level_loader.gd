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
	
	for i in len(file_paths):
		if not file_paths[i].ends_with(".tres"):
			continue
		var level_resource = load(level_dir + file_paths[i])
		level_resource.id = i
		level_resources[i] = level_resource
	
	print(level_resources)

func get_level_data_by_name(name: String):
	for level_resource in level_resources.values():
		if level_resource.name == name:
			return level_resource

func get_level_data_by_id(id):
	return level_resources.get(id)

func create(file_path: String):
	if not FileAccess.file_exists(file_path):
		return null

	var lvl_skeleton = FileAccess.open(file_path, FileAccess.READ)
	if lvl_skeleton == null:
		return null

	var lvl_skeleton_data = lvl_skeleton.get_as_text()
	lvl_skeleton.close()

	if lvl_skeleton_data.strip_edges() == "":
		return null

	var lines = lvl_skeleton_data.split("\n")
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
		
	if count == 0:
		original_data = data
		count += 1
	
	return _create_farm_model(data)


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
	

func _randomize():
		var transformed_data = []
		var rock_candidates = []
		var water_row_candidates = []
		
		var translucent_level = false
		
		var max_stones = 2
		var max_rivers = 1
		
		var default_value = null
		for y in range(original_data["height"]):
			var row = []
			for x in range(original_data["width"]):
				row.append(default_value)
			transformed_data.append(row)
	
  
		for i in range(original_data["FarmArray"].size()):
			for j in range(original_data["FarmArray"][i].size()):
				var item = original_data["FarmArray"][i][j]
				if item == null: 
					continue
				if item is Goal:
					continue
				if item.get_id() == 0 and item.is_translucent():
					rock_candidates.append([i,j])
					translucent_level = true
				elif item.get_id() == 1 and item.is_translucent():
					water_row_candidates.append(i)
					translucent_level = true
	
		if not translucent_level:
			var data = {"FarmArray": original_data["FarmArray"],
		"width":original_data["width"],
		"height":original_data["height"]}
			return _create_farm_model(data)

		for i in range(min(max_stones, rock_candidates.size())):
			if rock_candidates.size() > 0:
				var index = randi() % rock_candidates.size()
				var rock_index = rock_candidates[index]
				transformed_data[rock_index[0]][rock_index[1]] = Obstacle.ROCK()
				rock_candidates.pop_at(index)
	
   
		while water_row_candidates.size()>0 and max_rivers > 0:
			var river_row = water_row_candidates.pick_random()
			for j in original_data["width"]:
				var item = original_data["FarmArray"][river_row][j]
				if not (item is Obstacle and item.get_id() == 1):
					continue
				transformed_data[river_row][j] = Obstacle.WATER()
				water_row_candidates.erase(river_row)
				max_rivers -= 1
		
			
	
		var data = {"FarmArray": transformed_data,
		"width":original_data["width"],
		"height":original_data["height"]}
		
		return _create_farm_model(data)
