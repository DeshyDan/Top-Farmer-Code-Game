class_name FarmView
extends Node2D


@onready var dirt_terrain: TileMap =$Grid
@onready var robot: Robot = $Grid/Robot
@onready var inventory = $CanvasLayer/inventory

@export_group("Farm Size")
@export_range(2,15) var width:int = 5
@export_range(2,15) var height:int = 5

const PLANT_LAYER = 0
const SOIL_LAYER = 1
const SOIL_TERRAIN_SET = 0

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
	
	dirt_terrain.set_cells_terrain_connect(SOIL_LAYER, path, SOIL_TERRAIN_SET, 0)
	
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
			var farm_item: FarmItem = farm_model.get_plant_at_coord(Vector2i(x,y))
			if not (farm_item is Plant):
				continue
			var atlas_x = min(farm_item.age, 3)
			dirt_terrain.set_cell(PLANT_LAYER, Vector2i(x,y), farm_item.get_source_id(), Vector2i(atlas_x, 0))

func wait():
	robot.wait()

func harvest():

	var robot_coords:Vector2i = robot.get_coords()
	var tile_data: TileData = dirt_terrain.get_cell_tile_data(SOIL_LAYER, robot_coords)

	if tile_data:
		robot.harvest()
		dirt_terrain.set_cell(PLANT_LAYER, robot_coords,-1)
		
		if farm_model.is_harvestable(robot_coords):
			store(robot_coords)
		farm_model.remove(robot_coords)

func store(plant_coord:Vector2i):
	var harvested_plant:Plant = farm_model.get_plant_at_coord(plant_coord)
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
		else:
			print("Cannot place here")

func get_plant_type(plant_id:int):
	match(plant_id):
		0:
			return Plant.CORN()
		1:
			return Plant.TOMATO()

func move(dir): 
	robot_tile_coords = robot.move(dir)
	
func get_tile_position(coords: Vector2i):
	return dirt_terrain.map_to_local(coords)

func get_harvestables():
	return harvestables
	
func reset(original_farm_model : FarmModel):
	self.farm_model = original_farm_model
	robot_tile_coords = Vector2i(0,0) 
	robot.set_coords(robot_tile_coords)
	robot.position = get_tile_position(robot.get_coords())
	
	farm_model.remove_all_plants()
	harvestables.clear()
	inventory.clear()
	
	for x in farm_model.width:
		for y in farm_model.height:
			dirt_terrain.set_cell(PLANT_LAYER, Vector2i(x,y), -1)



