extends Node

@onready var corn_quantity = $inventoryWindow/GridContainer/CornSlot/QuantityText
@onready var tomato_quantity = $inventoryWindow/GridContainer/TomatoSlot/QuantityText


func store(plant_id:int, quantity: int  ):
	match plant_id:
		0:
			corn_quantity.text = str(quantity)
		1:
			tomato_quantity.text = str(quantity)
func set_goal_harvest_quantiy
func clear():
	corn_quantity.text = "0"+ "/" + harvest
	tomato_quantity.text = "0" "/" + harvest
