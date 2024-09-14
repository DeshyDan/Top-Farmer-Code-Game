class_name FarmModel
extends RefCounted

var grid_map = []
var width:int
var height:int 
var goal_pos : Vector2i
var max_random_rocks = 0
var max_random_rivers = 0

func _init(width:int , height:int):
	grid_map.resize(width * height)
	self.width = width
	self.height =height
	
func is_empty(coord: Vector2i)->bool:
	return ( grid_map[get_index(coord)] == null )
	
func add_farm_item(farm_item: FarmItem, coord: Vector2i):
	grid_map[get_index(coord)] = farm_item
	if farm_item is Goal:
		goal_pos = coord
func get_height():
	return height
	
func get_width():
	return width
	
func is_harvestable(coord):
	var item = grid_map[get_index(coord)]
	
	if item == null:
		return false
	elif item is Plant:
		return item.is_harvestable()
	else:
		return false

func is_obstacle(coord):
	return grid_map[get_index(coord)] is Obstacle

func is_water(coord):
	var farm_item = grid_map[get_index(coord)] 
	return farm_item is Obstacle and farm_item.id == 1

func set_harvestable(coord:Vector2i):
	if not grid_map[get_index(coord)]:
		return
	if grid_map[get_index(coord)] is Plant:
		grid_map[get_index(coord)].set_harvestable()

func remove(coord: Vector2i):
	grid_map[get_index(coord)] = null

func get_data():
	return grid_map

func get_index(coord: Vector2i):
	return (coord.x * height) + coord.y
	
func get_item_at_coord(coord:Vector2i):
	return grid_map[get_index(coord)]

func randomized() -> FarmModel:
	var result = FarmModel.new(width,height)
	var rock_candidates = []
	var river_candidates = []
	var rock_id = Obstacle.ROCK().id
	var water_id = Obstacle.WATER().id
	
	for x in width:
		for y in height:
			var coords = Vector2i(x,y)
			var item = get_item_at_coord(coords)
			if item == null:
				continue
			if item is Obstacle and item.is_translucent():
				if item.id == rock_id:
					rock_candidates.append(coords)
				elif item.id == water_id and not coords.y in river_candidates:
					river_candidates.append(coords.y)
			else:
				result.add_farm_item(item, coords)
	
	var rock_count = 0
	while rock_count < max_random_rocks and not rock_candidates.is_empty():
		var coords = rock_candidates.pick_random()
		rock_candidates.erase(coords)
		result.add_farm_item(Obstacle.ROCK(), coords)
		rock_count += 1
	
	var river_count = 0
	while river_count < max_random_rivers and not river_candidates.is_empty():
		var row = river_candidates.pick_random()
		for x in width:
			var coords = Vector2i(x, row)
			var item = get_item_at_coord(coords)
			if not item:
				continue
			if item.id == water_id:
				result.add_farm_item(Obstacle.WATER(), coords)
		river_count += 1
	
	return result
