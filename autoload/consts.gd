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

var LEVEL_GOALS = {
	"level 1": {
		PlantType.PLANT_CORN: 1,
		PlantType.PLANT_GRAPE: 1
	},
	"level 2": {
		PlantType.PLANT_CORN: 1,
		PlantType.PLANT_GRAPE: 1
	},
	"level 3": {
		PlantType.PLANT_CORN: 1,
		PlantType.PLANT_GRAPE: 1
	},
	"level 4": {
		PlantType.PLANT_CORN: 1,
		PlantType.PLANT_GRAPE: 1
	},
	"level 5": {
		PlantType.PLANT_CORN: 1,
		PlantType.PLANT_GRAPE: 1
	}
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
