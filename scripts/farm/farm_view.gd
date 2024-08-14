class_name FarmView
extends Node2D


@onready var dirt_terrain = $Grid
@onready var robot = $Grid/Robot
@onready var inventory = $inventory
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
var plant_growth_queue = []
var harvestables = {}

func plot_farm(width:int , height:int):
	var path = set_terrain_path(width, height)
	dirt_terrain.set_cells_terrain_connect(SOIL_LAYER, path, SOIL_TERRAIN_SET, 0)
	
	farm_model = FarmModel.new(width, height)
	
	robot.position = get_tile_position(robot.get_coords())

func set_terrain_path(width: int, height: int):
	var map = []
	for x in range(width):
		for y in range(height):
			map.append(Vector2i(x, y))

	return map


## TODO: Move harvesting logic to Farm Model
func handle_seeds(tile_map_pos, level, texture_source_id, atlas_coord, final_seed_level):
		dirt_terrain.set_cell(PLANT_LAYER, tile_map_pos, texture_source_id, atlas_coord)

		var growth_state = {
			"tile_map_pos": tile_map_pos,
			"level": level,
			"texture_source_id": texture_source_id,
			"atlas_coord": atlas_coord,
			"final_seed_level": final_seed_level
		}

		plant_growth_queue.append(growth_state)
		
func tick():
	## TODO: Move harvesting logic to Farm Model
	for growth_state in plant_growth_queue:
		var tile_map_pos = growth_state["tile_map_pos"]
		var level = growth_state["level"]
		var texture_source_id = growth_state["texture_source_id"]
		var atlas_coord = growth_state["atlas_coord"]
		var final_seed_level = growth_state["final_seed_level"]
  
		if level == final_seed_level:
			farm_model.set_harvestable(tile_map_pos)
			plant_growth_queue.erase(growth_state)
		else: 
			var new_atlas: Vector2i = Vector2i(atlas_coord.x + 1, atlas_coord.y)
			dirt_terrain.set_cell(PLANT_LAYER, tile_map_pos, texture_source_id, new_atlas)

			growth_state["level"] += 1
			growth_state["atlas_coord"] = new_atlas

func harvest():
	# get age of plant under robot, if age >= plant.max_age -> harvest
	# else remove plant, but dont add to inventory
	var robot_coords:Vector2i = robot.get_coords()
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

	var tile_data: TileData = dirt_terrain.get_cell_tile_data(SOIL_LAYER, robot.get_coords())

	if tile_data:
		var can_place_seed = tile_data.get_custom_data(CAN_PLACE_SEEDS)
		
		if can_place_seed and farm_model.is_empty(robot_tile_coords):
			robot.plant()
			var plant_type:Plant = get_plant_type(plant_id)
			
			dirt_terrain.set_cell(PLANT_LAYER, robot_tile_coords, plant_type.get_source_id(), atlas_coord)
			farm_model.add(plant_type, robot_tile_coords)
			handle_seeds(robot_tile_coords, 0,plant_type.get_source_id(), atlas_coord, 3)
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
#func _process(delta):
	#if Input.is_action_just_pressed("move_right"):
		#move.call_deferred(2)
	#if Input.is_action_just_pressed("move_up"):
		#move.call_deferred(0)
	#if Input.is_action_just_pressed("move_left"):
		#move.call_deferred(3)
	#if Input.is_action_just_pressed("move_down"):
		#move.call_deferred(1)
	#if Input.is_action_just_pressed("plantTomato"):
		#plant.call_deferred()
	#if Input.is_action_just_pressed("plantCorn"):
		#plant(0)
	#if Input.is_action_just_pressed("harvest"):
		#harvest.call_deferred()

