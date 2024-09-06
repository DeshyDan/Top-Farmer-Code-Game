class_name FarmView
extends Node2D

signal move_completed(successful:bool)
signal plant_completed(successful:bool)
signal harvest_completed(successful:bool)


@onready var dirt_terrain: TileMap =$Grid
@onready var robot: Robot = $Grid/Robot
@onready var inventory = $CanvasLayer/inventory

@export_group("Farm Size")
@export_range(2,15) var width:int = 5
@export_range(2,15) var height:int = 5

const PLANT_LAYER = 0
const SOIL_LAYER = 1
const ROCK_LAYER = 2
const SOIL_TERRAIN = 0
const WATER_TERRAIN = 1
const TRANSLUCENT_LAYER = 3
const OBSTACLES_LAYER = 1

const CORN_SOURCE_ID = 1
const CAN_PLACE_SEEDS = "can_place_seeds"

var farm_model:FarmModel
var robot_tile_coords: Vector2i = Vector2i(0,0)
var harvestables = {}

func plot_farm(farm_model:FarmModel):
	self.farm_model = farm_model
	var height = farm_model.get_height()
	var width = farm_model.get_width()
	var path = set_terrain_path(width, height)

	dirt_terrain.set_cells_terrain_connect(SOIL_LAYER, path, 0, SOIL_TERRAIN)
	for x in farm_model.width:
		for y in farm_model.height:
			var farm_item = farm_model.get_item_at_coord(Vector2i(x,y))
			if (farm_item is Obstacle):
				#water
				if farm_item.get_id() == 1:
					dirt_terrain.set_cells_terrain_connect(
						TRANSLUCENT_LAYER,
						[Vector2i(x, y)],
						0,
						WATER_TERRAIN, 
						false
					)
					var layer = TRANSLUCENT_LAYER if farm_item.is_translucent() else SOIL_LAYER
					dirt_terrain.set_cells_terrain_connect(
						layer,
						[Vector2i(x, y)],
						0,
						WATER_TERRAIN, 
						false
					)
					continue
				#rocks
				var layer = TRANSLUCENT_LAYER if farm_item.is_translucent() else ROCK_LAYER
				dirt_terrain.set_cell(layer, Vector2i(x,y), farm_item.get_source_id(), Vector2i(0, 0))
	redraw_farm()
	
	robot.position = get_tile_position(robot.get_coords())
	robot.set_boundaries(width,height)

func set_terrain_path(width: int, height: int):
	var map = []
	for x in range(width):
		for y in range(height):
			map.append(Vector2i(x, y))

	return map

func tick():
	for farm_item: FarmItem in farm_model.get_data():
		if not (farm_item is Plant):
			continue
		farm_item.age += 1
		if farm_item.age >= 3:
			farm_item.set_harvestable()
	redraw_farm()

func redraw_farm():
	for x in farm_model.width:
		for y in farm_model.height:
			var farm_item = farm_model.get_item_at_coord(Vector2i(x,y))
			if (farm_item is Plant):
				var atlas_x = min(farm_item.age, 3)
				dirt_terrain.set_cell(PLANT_LAYER, Vector2i(x,y), farm_item.get_source_id(), Vector2i(atlas_x, 0))
				
func wait():
	robot.wait()

func harvest():

	var robot_coords:Vector2i = robot.get_coords()
	var tile_data: TileData = dirt_terrain.get_cell_tile_data(SOIL_LAYER, robot_coords)

	if tile_data and farm_model.get_item_at_coord(robot_coords) is Plant:
		robot.harvest()
		dirt_terrain.set_cell(PLANT_LAYER, robot_coords,-1)
		
		if farm_model.is_harvestable(robot_coords):
			store(robot_coords)
			harvest_completed.emit(true)
		farm_model.remove(robot_coords)
		harvest_completed.emit(false)

func store(plant_coord:Vector2i):
	var harvested_plant:Plant = farm_model.get_item_at_coord(plant_coord)
	var plant_id = harvested_plant.get_id()
	if plant_id in harvestables:
		var old_val = harvestables[plant_id]
		harvestables[plant_id] = old_val + 1
	else:
		harvestables[plant_id] = 1
	inventory.store(plant_id,harvestables[plant_id])
	
func plant(plant_id:int=1):
	
	var atlas_coord: Vector2i = Vector2i(0, 0)
	
	var tile_data: TileData = dirt_terrain.get_cell_tile_data(SOIL_LAYER, robot_tile_coords)

	if tile_data:
		var can_place_seed = tile_data.get_custom_data(CAN_PLACE_SEEDS)
		
		if can_place_seed and farm_model.is_empty(robot_tile_coords):
			robot.plant()
			var plant_type:Plant = get_plant_type(plant_id)
			
			dirt_terrain.set_cell(PLANT_LAYER, robot_tile_coords, plant_type.get_source_id(), atlas_coord)
			farm_model.add_farm_item(plant_type, robot_tile_coords)
			plant_completed.emit(true)
		else:
			plant_completed.emit(false)
			print("Cannot place here")

func get_plant_type(plant_id:int):
	match(plant_id):
		0:
			return Plant.CORN()
		1:
			return Plant.TOMATO()

func move(dir): 
	var vec: Vector2i
	match dir:
		Const.Direction.NORTH:
			vec = Vector2i.UP
		Const.Direction.SOUTH:
			vec = Vector2i.DOWN
		Const.Direction.EAST:
			vec = Vector2i.RIGHT
		Const.Direction.WEST:
			vec = Vector2i.LEFT
			
	if (is_out_of_bounds(robot_tile_coords + vec)) or (farm_model.is_obstacle(robot_tile_coords + vec)):
		move_completed.emit(false)
		return
	robot_tile_coords = robot.move(vec)
	move_completed.emit(true)

func is_out_of_bounds(coords: Vector2i):
	return coords.x >= farm_model.get_width() or coords.x < 0 or coords.y >= farm_model.get_height() or coords.y < 0	

func get_tile_position(coords: Vector2i):
	return dirt_terrain.map_to_local(coords)

func get_harvestables():
	return harvestables
	
func reset(original_farm_model : FarmModel):
	self.farm_model = original_farm_model
	robot_tile_coords = Vector2i(0,0) 
	robot.set_coords(robot_tile_coords)
	robot.position = get_tile_position(robot.get_coords())
	robot.idle()
	
	remove_all_plants()
	harvestables.clear()
	inventory.clear()
	
func remove_all_plants():
	for x in farm_model.width:
		for y in farm_model.height:
			var farm_item = farm_model.get_item_at_coord(Vector2i(x,y))
			if (farm_item is Plant):
				farm_model.remove(Vector2i(x,y))
				dirt_terrain.set_cell(PLANT_LAYER, Vector2i(x,y), -1)



