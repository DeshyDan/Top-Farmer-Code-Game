class_name FarmView
extends Node2D
# Class takes in requests from Level and forwards it to the FarmModel,
# Robot and Inventory and updates the view whenever a change is made. It then 
# sends a response back to Level 
# It also provides the logic for determining the service to forward the request
# to and appropriate response to Level. 

signal move_completed(successful:bool)
signal plant_completed(successful:bool)
signal harvest_completed(successful:bool)
signal goal_pos_met


@onready var _farm_tilemap: TileMap =$Grid
@onready var _robot: Robot = $Grid/Robot
@onready var _inventory = $CanvasLayer/inventory
@onready var _pickup_spawner = $PickupSpawner

@export_group("Farm Size")
@export_range(2,15) var width:int = 5
@export_range(2,15) var height:int = 5

const CORN_SOURCE_ID = 1
const CAN_PLACE_SEEDS = "can_place_seeds"

var _farm_model: FarmModel
var _robot_tile_coords: Vector2i = Vector2i(0,0)
var _harvestables = {}
var _original_farm_model:FarmModel

func plot_farm(farm_model:FarmModel):
	self._farm_model = farm_model
	
	var height = _farm_model.get_height()
	var width = _farm_model.get_width()
	
	_farm_tilemap.fill_with_dirt(width, height)
	
	for x in _farm_model.get_width():
		for y in _farm_model.get_height():
			var coords = Vector2i(x,y)
			var farm_item = _farm_model.get_item_at_coord(coords)
			if farm_item is Obstacle:
				#water
				if farm_item.get_id() == 1:
					_farm_tilemap.set_water_tile(coords, farm_item)
					continue
				#rocks
				_farm_tilemap.set_rock_tile(coords, farm_item)
			if farm_item is Goal:
				_farm_tilemap.set_goal(coords, farm_item)
	redraw_farm()
	
	_robot.position = get_tile_position(_robot.get_coords())
	_robot.set_boundaries(width,height)


func tick():
	for farm_item: FarmItem in _farm_model.get_data():
		if not (farm_item is Plant):
			continue
		farm_item.grow()
		if farm_item.get_age() >= 3:
			farm_item.set_harvestable()
	redraw_farm()

func redraw_farm():
	for x in _farm_model.get_width():
		for y in _farm_model.get_height():
			var farm_item = _farm_model.get_item_at_coord(Vector2i(x,y))
			if (farm_item is Plant):
				_farm_tilemap.set_plant(Vector2i(x,y), farm_item)

func wait():
	_robot.wait()

func harvest():
	var _robot_coords:Vector2i = _robot.get_coords()
	var tile_data: TileData = _farm_tilemap.get_soil_data(_robot_coords)
	var did_harvest = false
	if tile_data and _farm_model.get_item_at_coord(_robot_coords) is Plant:
		_robot.harvest()
		_farm_tilemap.erase_plant(_robot_tile_coords)
		
		if _farm_model.is_harvestable(_robot_coords):
			_store(_robot_coords)
			did_harvest = true
		_farm_model.remove(_robot_coords)
	harvest_completed.emit(did_harvest)

func set_goal_state(goal_state):
	_inventory.set_goal_state(goal_state)

func _store(plant_coord:Vector2i):
	var harvested_plant:Plant = _farm_model.get_item_at_coord(plant_coord)
	var plant_id = harvested_plant.get_id()

	_pickup_spawner.animate_pickup(plant_coord, harvested_plant)
	
	if plant_id in _harvestables:
		var old_val = _harvestables[plant_id]
		_harvestables[plant_id] = old_val + 1
	else:
		_harvestables[plant_id] = 1
	_inventory.store(plant_id,_harvestables[plant_id])

func plant(plant_id:int=1):
	
	var tile_data: TileData = _farm_tilemap.get_soil_data(_robot_tile_coords)

	if not tile_data:
		return
	
	var can_place_seed = tile_data.get_custom_data(CAN_PLACE_SEEDS)
	
	if can_place_seed and _farm_model.is_empty(_robot_tile_coords):
		_robot.plant()
		var plant_type:Plant = get_plant_type(plant_id)
		
		_farm_tilemap.set_plant(_robot_tile_coords, plant_type)
		_farm_model.add_farm_item(plant_type, _robot_tile_coords)
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
	var next_move = _robot_tile_coords + vec
	if (_is_out_of_bounds(next_move)) or (_farm_model.is_obstacle(next_move) and !_farm_model.is_water(next_move)):
		move_completed.emit(false)
		return
	_robot_tile_coords = _robot.move(vec)
	move_completed.emit(true)
	if vec == _farm_model.get_goal_pos():
		goal_pos_met.emit()

func _is_out_of_bounds(coords: Vector2i):
	return coords.x >= _farm_model.get_width() or coords.x < 0 or coords.y >= _farm_model.get_height() or coords.y < 0	

func get_tile_position(coords: Vector2i):
	return _farm_tilemap.map_to_local(coords)

func get_harvestables():
	return _harvestables
	
func reset():
	_farm_model = _original_farm_model
	_robot_tile_coords = Vector2i(0,0)
	_robot.set_coords(_robot_tile_coords)
	_robot.position = get_tile_position(_robot.get_coords())
	_robot.reset()
	_robot.idle()
	
	remove_all_plants()
	_harvestables.clear()
	_inventory.clear()
		
	plot_farm(_farm_model)

func set_original_farm_model(farm_model: FarmModel):
	_original_farm_model = farm_model
	
func get_original_farm_model():
	return _original_farm_model
	
func remove_all_plants():
	_farm_tilemap.clear_plants()
	#farm_model.remove_all_plants()
	
func get_farm_model():
	return _farm_model

func get_inventory():
	return _inventory

func clear_farm():
	_farm_tilemap.clear()
	
func get_farm_tilemap():
	return _farm_tilemap
	
func get_robot_tile_coords():
	return _robot_tile_coords
