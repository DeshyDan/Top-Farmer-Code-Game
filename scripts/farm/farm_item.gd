class_name FarmItem
extends RefCounted
# This class provides the blueprint for creating elements that will be placed in
# a FarmModel. 

var texture_source_id:int
var id: int

func _init(id:int , texture_source_id:int):
	self.id = id
	self.texture_source_id = texture_source_id
	
func get_id():
	return self.id
	
func get_source_id():
	return self.texture_source_id

func is_empty():
	return id == 0 and texture_source_id == 0

static func EMPTY() -> FarmItem:
	return FarmItem.new(0, 0)
