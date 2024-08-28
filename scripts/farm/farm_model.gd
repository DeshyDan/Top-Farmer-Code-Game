class_name FarmModel
extends RefCounted

var grid_map = []
var width:int
var height:int 

func _init(width:int , height:int):
	grid_map.resize(width * height)
	self.width = width
	self.height =height
	

func is_empty(coord: Vector2i)->bool:
	return ( grid_map[get_index(coord)] == null )
	
func add_plant(plant:Plant, coord: Vector2i):
	grid_map[get_index(coord)] = plant
	print(get_data())
	
func add_obstacle(obstacle:Obstacle, coord: Vector2i):
	grid_map[get_index(coord)] = obstacle
	print(get_data())

func get_height():
	return height
	
func get_width():
	return width
	
func is_harvestable(coord):
	var plant = grid_map[get_index(coord)]
	if plant == null:
		return false
	return plant.is_harvestable()
	
func set_harvestable(coord:Vector2i):
	if not grid_map[get_index(coord)]:
		return
	grid_map[get_index(coord)].set_harvestable()

func remove(coord: Vector2i):
	grid_map[get_index(coord)] = null

func get_data():
	return grid_map

func get_index(coord:Vector2i):
	return (coord.x * height) + coord.y
	
func get_plant_at_coord(coord:Vector2i):
	return grid_map[get_index(coord)]
	
func remove_all_plants():
	for i in range(grid_map.size()):
		grid_map[i] = null
