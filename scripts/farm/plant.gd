class_name Plant
extends FarmItem
# This class represents a plant, a collectable FarmItem that can be placed in
# the FarmModel.
# It also contains to the logic for creating the types of Plant to be used
# in game as well as fuctions to modify their attributes

const FINAL_SEED_LEVEL = 3

var plant_type: int
var _age: int
var _harvestable: bool

func _init(id:int , texture_source_id:int):
	self._id = id
	self._texture_source_id = texture_source_id
	self._harvestable = false
	self._age = 0 

static func CORN():
	return Plant.new(0, 1)
	
static func TOMATO():
	return Plant.new(1, 2)
	
func get_id():
	return self._id

func get_source_id():
	return self._texture_source_id
	
func get_age():
	return _age
	
func grow():
	_age += 1

func get_final_seed_level():
	return FINAL_SEED_LEVEL

func is_harvestable():
	return self._harvestable
	
func set_harvestable():
	self._harvestable = true
