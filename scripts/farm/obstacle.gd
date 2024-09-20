class_name Obstacle
extends FarmItem
# Class represents a farm item that hinders a Robot from moving

var _translucent:bool


func _init(id:int , texture_source_id:int , translucent:bool ):
	self._id = id
	self._translucent = translucent
	self._texture_source_id = texture_source_id

static func ROCK():
	return Obstacle.new(0, 3, false)

static func WATER():
	return Obstacle.new(1, 4,false)
	
func get_id():
	return self._id
	
func get_source_id():
	return self._texture_source_id
	
func is_translucent():
	return self._translucent
	
func set_translucent(new_translucent:bool):
	self._translucent = new_translucent
