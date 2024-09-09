extends TextureRect

const CORN_TEXTURE = "res://assets/textures/objects/CornIcon.png"
const TOMATO_TEXTURE = "res://assets/textures/objects/tomatoIcon.png"

#TODO:Think of a better name mann
func load_texture(plant_id:int):
	match plant_id:
		Const.PlantType.PLANT_CORN:
			texture = load(CORN_TEXTURE)
		Const.PlantType.PLANT_GRAPE:
			texture = load(TOMATO_TEXTURE)
