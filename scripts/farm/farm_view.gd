class_name FarmView
extends Node2D

signal move_completed(successful:bool)
signal plant_completed(successful:bool)
signal harvest_completed(successful:bool)
signal goal_pos_met


@onready var farm_tilemap: TileMap =$Grid
@onready var robot: Robot = $Grid/Robot
@onready var inventory = $CanvasLayer/inventory
@onready var pickup_spawner = $PickupSpawner

@export_group("Farm Size")
@export_range(2,15) var width:int = 5
@export_range(2,15) var height:int = 5

const CORN_SOURCE_ID = 1
const CAN_PLACE_SEEDS = "can_place_seeds"

var farm_model: FarmModel
var robot_tile_coords: Vector2i = Vector2i(0,0)
var harvestables = {}
var original_farm_model:FarmModel

func plot_farm(farm_model:FarmModel):
	self.farm_model = farm_model
	
	var height = farm_model.get_height()
	var width = farm_model.get_width()
	
	farm_tilemap.fill_with_dirt(width, height)
	
	for x in farm_model.width:
		for y in farm_model.height:
			var coords = Vector2i(x,y)
			var farm_item = farm_model.get_item_at_coord(coords)
			if farm_item is Obstacle:
				#water
				if farm_item.get_id() == 1:
					farm_tilemap.set_water_tile(coords, farm_item)
					continue
				#rocks
				farm_tilemap.set_rock_tile(coords, farm_item)
			if farm_item is Goal:
				farm_tilemap.set_goal(coords, farm_item)
	redraw_farm()
	
	robot.position = get_tile_position(robot.get_coords())
	robot.set_boundaries(width,height)


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
				farm_tilemap.set_plant(Vector2i(x,y), farm_item)
				
func wait():
	robot.wait()

func harvest():
	var robot_coords:Vector2i = robot.get_coords()
	var tile_data: TileData = farm_tilemap.get_soil_data(robot_coords)
	var did_harvest = false
	if tile_data and farm_model.get_item_at_coord(robot_coords) is Plant:
		robot.harvest()
		farm_tilemap.erase_plant(robot_tile_coords)
		
		if farm_model.is_harvestable(robot_coords):
			store(robot_coords)
			did_harvest = true
		farm_model.remove(robot_coords)
	harvest_completed.emit(did_harvest)

func set_goal_state(goal_state):
	inventory.set_goal_state(goal_state)

func store(plant_coord:Vector2i):
	var harvested_plant:Plant = farm_model.get_item_at_coord(plant_coord)
	var plant_id = harvested_plant.get_id()

	pickup_spawner.animate_pickup(plant_coord, harvested_plant)
	
	if plant_id in harvestables:
		var old_val = harvestables[plant_id]
		harvestables[plant_id] = old_val + 1
	else:
		harvestables[plant_id] = 1
	inventory.store(plant_id,harvestables[plant_id])

func plant(plant_id:int=1):
	
	var tile_data: TileData = farm_tilemap.get_soil_data(robot_tile_coords)

	if not tile_data:
		return
	
	var can_place_seed = tile_data.get_custom_data(CAN_PLACE_SEEDS)
	
	if can_place_seed and farm_model.is_empty(robot_tile_coords):
		robot.plant()
		var plant_type:Plant = get_plant_type(plant_id)
		
		farm_tilemap.set_plant(robot_tile_coords, plant_type)
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
	var next_move = robot_tile_coords + vec
	if (is_out_of_bounds(next_move)) or (farm_model.is_obstacle(next_move) and !farm_model.is_water(next_move)):
		move_completed.emit(false)
		return
	robot_tile_coords = robot.move(vec)
	move_completed.emit(true)
	if vec == farm_model.goal_pos:
		goal_pos_met.emit()

func is_out_of_bounds(coords: Vector2i):
	return coords.x >= farm_model.get_width() or coords.x < 0 or coords.y >= farm_model.get_height() or coords.y < 0	

func get_tile_position(coords: Vector2i):
	return farm_tilemap.map_to_local(coords)

func get_harvestables():
	return harvestables
	
func reset():
	farm_model = original_farm_model
	robot_tile_coords = Vector2i(0,0)
	robot.set_coords(robot_tile_coords)
	robot.position = get_tile_position(robot.get_coords())
	robot.reset()
	robot.idle()
	
	remove_all_plants()
	harvestables.clear()
	inventory.clear()
		
	plot_farm(farm_model)

func set_original_farm_model(farm_model: FarmModel):
	original_farm_model = farm_model

func remove_all_plants():
	farm_tilemap.clear_plants()
	#farm_model.remove_all_plants()

func clear_farm():
	farm_tilemap.clear()
