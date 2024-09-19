class_name FarmModel
extends RefCounted
# Class represents the data structure used to store FarmItems for a farm.
# It provides functionality like adding, getting, searching and modifying a farm 
# item.
# Addionally, it exposes a function that allows users of this class to randomise
# the stored FarmItems.

var _grid_map = [] 
var _width:int
var _height:int 
var _goal_pos : Vector2i
var _max_random_rocks = 0
var _max_random_rivers = 0

func _init(width:int , height:int):
	_grid_map.resize(width * height)
	_grid_map.fill(FarmItem.EMPTY())
	self._width = width
	self._height = height
	
func is_empty(coord: Vector2i)->bool:
	return ( _grid_map[_get_index(coord)].is_empty())
	
func add_farm_item(farm_item: FarmItem, coord: Vector2i):
	_grid_map[_get_index(coord)] = farm_item
	if farm_item is Goal:
		_goal_pos = coord

func get_height():
	return _height
	
func get_width():
	return _width
	
func is_harvestable(coord):
	var item = _grid_map[_get_index(coord)]
	
	return item is Plant and item.is_harvestable()

func is_obstacle(coord):
	return _grid_map[_get_index(coord)] is Obstacle

func is_water(coord):
	var farm_item = _grid_map[_get_index(coord)] 
	return farm_item is Obstacle and farm_item.get_id() == 1

func set_harvestable(coord:Vector2i):
	if _grid_map[_get_index(coord)] is Plant:
		_grid_map[_get_index(coord)].set_harvestable()

func remove(coord: Vector2i):
	_grid_map[_get_index(coord)] = FarmItem.EMPTY()

func get_data():
	return _grid_map

func _get_index(coord: Vector2i):
	return (coord.x * _height) + coord.y
	
func get_item_at_coord(coord:Vector2i):
	return _grid_map[_get_index(coord)]

func randomized() -> FarmModel:
	var result = FarmModel.new(_width,_height)
	var rock_candidates = []
	var river_candidates = []
	var rock_id = Obstacle.ROCK().get_id()
	
	for x in _width:
		for y in _height:
			var coords = Vector2i(x,y)
			var item = get_item_at_coord(coords)
			if is_obstacle(coords) and item.is_translucent():
				if item.get_id() == rock_id:
					rock_candidates.append(coords)
				elif is_water(coords) and not coords.y in river_candidates:
					river_candidates.append(coords.y)
			else:
				result.add_farm_item(item, coords)
	
	var rock_count = 0
	while rock_count < _max_random_rocks and not rock_candidates.is_empty():
		var coords = rock_candidates.pick_random()
		rock_candidates.erase(coords)
		result.add_farm_item(Obstacle.ROCK(), coords)
		rock_count += 1
	
	var river_count = 0
	while river_count < _max_random_rivers and not river_candidates.is_empty():
		var row = river_candidates.pick_random()
		for x in _width:
			var coords = Vector2i(x, row)
			if is_water(coords):
				result.add_farm_item(Obstacle.WATER(), coords)
		river_count += 1
	
	return result

func get_goal_pos():
	return _goal_pos

func set_goal_pos(goal_pos:Vector2i):
	_goal_pos = goal_pos

func set_max_random_rivers(max_random_rivers: int):
	_max_random_rivers = max_random_rivers

func get_max_random_rivers():
	return _max_random_rivers
	
func set_max_random_rocks(max_random_rivers:int):
	_max_random_rocks = max_random_rivers

func get_max_random_rock():
	return _max_random_rivers
