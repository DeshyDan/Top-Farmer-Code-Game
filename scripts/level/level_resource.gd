class_name LevelResource
extends Resource

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
