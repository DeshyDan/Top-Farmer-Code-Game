class_name Plant
extends RefCounted

var plant_type: int
var age: int
var harvestable: bool
var growth_factor: int
var texture_source_id:int

func _init(growth_factor:int , texture_source_id):
	self.growth_factor = growth_factor
	self.texture_source_id = texture_source_id
	self.harvestable = false

static func CORN():
	return Plant.new(4, 1)
	
static func TOMATO():
	return Plant.new(4, 2)

func get_growth_factor():
	return growth_factor

func get_source_id():
	return self.texture_source_id
	
func is_harvestable():
	return self.harvestable
	
func set_harvestable():
	self.harvestable = true
