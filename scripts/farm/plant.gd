class_name Plant
extends FarmItem

const FINAL_SEED_LEVEL = 3

var plant_type: int
var age: int
var max_age: int
var harvestable: bool
var growth_factor: int

func _init(id:int , texture_source_id:int , growth_factor:int ):
	self.id = id
	self.growth_factor = growth_factor
	self.texture_source_id = texture_source_id
	self.harvestable = false
	self.age = 0 

static func CORN():
	return Plant.new(0, 1, 4)
	
static func TOMATO():
	return Plant.new(1, 2, 4)
	
func get_id():
	return self.id
	
func get_growth_factor():
	return growth_factor

func get_source_id():
	return self.texture_source_id
func get_age():
	return age
	
func grow():
	age += age
func get_final_seed_level():
	return FINAL_SEED_LEVEL

func is_harvestable():
	return self.harvestable
	
func set_harvestable():
	self.harvestable = true
