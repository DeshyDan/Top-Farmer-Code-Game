class_name FarmModel
extends RefCounted

var grid_map = []
var width:int
var height:int 
var goal_pos : Vector2i

func _init(width:int , height:int):
	grid_map.resize(width * height)
	self.width = width
	self.height =height
	
func is_empty(coord: Vector2i)->bool:
	return ( grid_map[get_index(coord)] == null )
	
func add_farm_item(farm_item: FarmItem, coord: Vector2i):
	grid_map[get_index(coord)] = farm_item
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

func get_index(coord:Vector2i):
	return (coord.x * height) + coord.y
	
func get_item_at_coord(coord:Vector2i):
	return grid_map[get_index(coord)]
	
