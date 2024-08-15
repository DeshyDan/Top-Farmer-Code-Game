extends Node

enum PlantType {
	PLANT_CORN,
	PLANT_GRAPE,
}

enum Direction {
	NORTH,
	SOUTH,
	EAST,
	WEST,
}

var DEFAULT_BUILTIN_CONSTS = {
	"NORTH": Const.Direction.NORTH,
	"SOUTH": Const.Direction.SOUTH,
	"EAST": Const.Direction.EAST,
	"WEST": Const.Direction.WEST,
	# double define to make things easier for player
	"UP": Const.Direction.NORTH,
	"DOWN": Const.Direction.SOUTH,
	"RIGHT": Const.Direction.EAST,
	"LEFT": Const.Direction.WEST,
	"GRAPE": Const.PlantType.PLANT_GRAPE,
	"CORN": Const.PlantType.PLANT_CORN,
}
