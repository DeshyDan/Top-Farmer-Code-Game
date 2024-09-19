class_name Goal
extends FarmItem
# This class represents a collectable farm item needed to complete a level

func _init(id:int , texture_source_id:int ):
	self._id = id
	self._texture_source_id = texture_source_id

static func GOAL():
	return Goal.new(0, 4)
	
func get_id():
	return self._id
	
func get_source_id():
	return self._texture_source_id
	
