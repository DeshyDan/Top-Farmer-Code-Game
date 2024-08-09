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
@onready var robot = $TileMap/Robot

func _ready():
	#tile_map.set_cell(1, Vector2i(0,0),0,Vector2i(8,3))
	robot.position = get_tile_position(robot_tile_coords)
	
func plant(plant: Plant):
	match plant:
		Plant.Carrot:
			tile_map.set_cell(1, robot_tile_coords, 0, Vector2i(8,3))

func get_tile_position(coords):
	return tile_map.map_to_local(coords)

#robot stuff
enum Direction {
	NORTH, # = 0
	SOUTH, # = 1
	EAST,
	WEST # = 3
}

const move_dist = 50
var robot_tile_coords: Vector2i = Vector2i(0,0)

func move(dir: Direction, time: float = 0.1):
	var vec: Vector2i
	match dir:
		Direction.NORTH:
			vec = Vector2i.UP
		Direction.SOUTH:
			vec = Vector2i.DOWN
		Direction.EAST:
			vec = Vector2i.RIGHT
		Direction.WEST:
			vec = Vector2i.LEFT
	# robot_tile_coord = (0,0) + (0,1) -> (0,1)
	robot_tile_coords += vec
	var tween = create_tween()
	var new_local_position = get_tile_position(robot_tile_coords)
	tween.tween_property(robot, "position", new_local_position, time)

