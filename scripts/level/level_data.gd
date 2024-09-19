class_name LevelData
extends Resource
# Class defines the data structure of a Level
# It also provides functionality of accessing and setting different attributes of
# a level

const MAX_WIDTH = 100
const MAX_HEIGHT = 100

@export var id: int = -1

@export var name: String = "default level name"
@export var corn_goal: int = 0
@export var grape_goal: int = 0
@export var goal_position: Vector2i = Vector2i.ZERO

@export_category("Farm Model")
@export_multiline var farm_string = ""

@export_category("Randomization")
@export var max_random_rocks: int = 0
@export var max_random_rivers: int = 0

@export_category("Hint")
@export_multiline var level_hint: String = "No hint for this level... Good luck!"

@export_category("Developer Solution")
@export_multiline var source_code: String = ""
@export var dev_score: int = 0
@export var dev_tick_count: int = 0

func get_goal_state() -> Dictionary:
	return {
		Const.PlantType.PLANT_CORN: corn_goal,
		Const.PlantType.PLANT_GRAPE: grape_goal,
	}

func get_farm_model() -> FarmModel:
	var row_strings = farm_string.split("\n", false)
	
	var height = min(row_strings.size(), MAX_HEIGHT)
	var width = 0
	
	if not row_strings.is_empty():
		width = len(row_strings[0])
	
	for row_string in row_strings:
		width = min(width, len(row_string))
	
	var result = FarmModel.new(width, height)
	
	for x in range(width):
		for y in range(height):
			var row_string = row_strings[y]
			var farm_char = row_string[x]
			var coords = Vector2i(x,y)
			var item: FarmItem
			match farm_char:
				"#":
					item = FarmItem.EMPTY()
				"r":
					item = Obstacle.ROCK()
					
				"w":
					item = Obstacle.WATER()
					
				"s":
					item = Obstacle.ROCK()
					item.set_translucent(true)
				"l":
					item = Obstacle.WATER()
					item.set_translucent(true)
			
			if item is Obstacle and item.id == Obstacle.WATER().id:
				if x == 0 or y == 0 or x == width-1 or y == height-1:
					continue	# no water tiles on the edge because the tileset doesn't support it
			
			result.add_farm_item(item, coords)
	
	if goal_position != Vector2i.ZERO:
		result.goal_pos = goal_position
		result.add_farm_item(Goal.GOAL(), goal_position)
	
	result.max_random_rivers = max_random_rivers
	result.max_random_rocks = max_random_rocks
	
	return result
