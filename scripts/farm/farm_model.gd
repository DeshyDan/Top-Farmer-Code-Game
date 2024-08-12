class_name FarmModel
extends RefCounted

var grid_map:Array = []
var width:int
var height:int 

func _init(width:int , height:int):
	grid_map.resize(width * height)
	self.width = width
	self.height =height
	

func is_empty(coord: Vector2i)->bool:
	return ( grid_map[get_index(coord)] == null )
	
func add(value:int, coord: Vector2i):
	grid_map[get_index(coord)] = value
	print(get_data())
	
func setHarvestable(coord:Vector2i):
	pass
func remove(coord: Vector2i):
	grid_map[get_index(coord)] = null

func get_data():
	return grid_map

func get_index(coord:Vector2i):
	return (coord.x * height) + coord.y
