extends Control
# This class contains the logic for creating a visual representaion of the amount
# of harvestable Plants collected during gameplay.
# It also shows the harvest goal for the level during gameplay

@export var corn_quantity: Label
@export var corn_goal: Label

@export var tomato_quantity: Label
@export var tomato_goal: Label

# TODO: MAKE THIS INVENTORY LOGIC MORE DYNAMIC

func store(plant_id:int, quantity: int  ):
	match plant_id:
		0:
			corn_quantity.text = str(quantity)
		1:
			tomato_quantity.text = str(quantity)
func set_goal_state(goal_state):
	for i in goal_state:
		match i :
			Const.PlantType.PLANT_CORN:
				# TODO: Make "/" a separe label
				corn_goal.text = "/" + str(goal_state[i])
			Const.PlantType.PLANT_GRAPE:
				tomato_goal.text = "/" + str(goal_state[i])
				
func clear():
	corn_quantity.text = "0"
	tomato_quantity.text = "0"
