class_name Farm
extends Node2D
@onready var tile_map = $TileMap
var tile_set_source
enum Plant {
	Carrot,
	#Berries,
	#Wheat,
	#Corn
}

func _ready():
	#tile_map.set_cell(1, Vector2i(0,0),0,Vector2i(8,3))
	pass
	
func plant(plant: Plant, coords):
	var tile_type = null
	match plant:
		Plant.Carrot:
			tile_map.set_cell(1, coords, 0, Vector2i(8,3))

func get_tile_position(coords):
	return tile_map.map_to_local(coords)
