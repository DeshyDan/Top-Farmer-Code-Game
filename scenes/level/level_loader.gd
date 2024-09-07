extends Node
class_name LevelLoader

var lvl_array:Array
var lvl_array_items:Array

var count = 0
var original_data : Dictionary

func create(level:int):
	
	var file_path = "res://assets/levels/lvl_" + str(level) + ".txt"
	var lvl_skeleton = FileAccess.open(file_path, FileAccess.READ)
	
	var lvl_skeleton_data = lvl_skeleton.get_as_text()
	
	var lines = lvl_skeleton_data.split("\n")
	var height = 0
	var width = 0
	
	for line in lines:
		if line != "":
			var items = line.split(",")
			lvl_array.append(items)
			width = len(items)
			height += 1

	var default_value = null
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(default_value)
		lvl_array_items.append(row)
	
	for i in range(0,height):
		for j in range(0,width):
			var item = lvl_array[i][j]
			# # -> bare land
			# s -> translucent rock
			# r -> rock
			# l -> translucent water
			# w -> water
			## TODO: use some kind of enum to map symbol to obstacle name
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
				var water = Obstacle.WATER()
				lvl_array_items[i][j] = water
			elif item == "l":
				var water = Obstacle.WATER()
				water.set_translucent(true)
				lvl_array_items[i][j] = water
				
	var data = {
		"FarmArray":lvl_array_items,
		"width":width,
		"height":height}
		
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
				pass
			else:
				farm_model.add_farm_item(item,coord)
	
	return farm_model
	
func _randomize():
		var transformed_data = []
		var rock_candidates = []
		var water_row_candidates = []
		
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
				if item.get_id() == 0 and item.is_translucent():
					rock_candidates.append([i,j])
				elif item.get_id() == 1 and item.is_translucent():
					water_row_candidates.append(i)
	

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
