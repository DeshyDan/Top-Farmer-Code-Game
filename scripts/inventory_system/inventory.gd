extends Control

@onready var corn_quantity = $inventoryWindow/GridContainer/CornSlot/QuantityText
@onready var corn_goal = $inventoryWindow/GridContainer/CornSlot/GoalState

@onready var tomato_quantity = $inventoryWindow/GridContainer/TomatoSlot/QuantityText
@onready var tomato_goal = $inventoryWindow/GridContainer/TomatoSlot/GoalState

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
				corn_goal.text = "/" + str(goal_state[i])
				
func clear():
	corn_quantity.text = "0"
	tomato_quantity.text = "0"
