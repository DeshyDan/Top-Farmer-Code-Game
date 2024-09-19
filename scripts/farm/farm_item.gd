class_name FarmItem
extends RefCounted
# This class provides the blueprint for creating elements that will be placed in
# a FarmModel. 

var _texture_source_id:int
var _id: int

func _init(id:int , texture_source_id:int):
	self._id = id
	self._texture_source_id = texture_source_id
	
func get_id():
	return self._id
	
func get_source_id():
	return self._texture_source_id

func is_empty():
	return _id == 0 and _texture_source_id == 0

static func EMPTY() -> FarmItem:
	return FarmItem.new(0, 0)
