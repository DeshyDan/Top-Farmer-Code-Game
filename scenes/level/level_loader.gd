extends Node
class_name LevelLoader

var lvl_array:Array
var lvl_array_items:Array

func create(data:String):
	var lines = data.split("\n")
	var height = 0
	var width = 0
	
	for line in lines:
		if line != "":
			var items = line.split(",")
			lvl_array.append(items)
			width = len(items)
			height += 1

	var default_value = null
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(default_value)
		lvl_array_items.append(row)
	
	for i in range(0,height):
		for j in range(0,width):
			var item = lvl_array[i][j]
			# # -> bare land
			# s -> translucent rock
			# r -> rock
			# l -> translucent water
			# w -> water
			## TODO: use some kind of enum to map symbol to obstacle name
			var coord: Vector2i = Vector2i(j, i)
			if item == "#":
				lvl_array_items[i][j] = null
			elif item == "r":
				var rock = Obstacle.ROCK()
				lvl_array_items[i][j] = rock
			elif item == "s":
				var rock = Obstacle.ROCK()
				rock.set_translucent(true)
				lvl_array_items[i][j] = rock
			elif item == "w":
				var water = Obstacle.WATER()
				lvl_array_items[i][j] = water
			elif item == "l":
				var water = Obstacle.WATER()
				water.set_translucent(true)
				lvl_array_items[i][j] = water
				
	print("Hi")
	return {
		"FarmArray":lvl_array_items,
		"width":width,
		"height":height}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
