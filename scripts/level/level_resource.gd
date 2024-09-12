class_name LevelResource
extends Resource

@export var id: int = -1

@export var name: String = "default level name"
@export var corn_goal: int = 0
@export var grape_goal: int = 0

@export_category("Farm Model")
@export_multiline var farm_string = ""


@export_category("Hint")
@export_multiline var level_hint: String = "No hint for this level... Good luck!"
