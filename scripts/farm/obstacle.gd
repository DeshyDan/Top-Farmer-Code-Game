class_name Obstacle
extends FarmItem
# Class represents a farm item that hinders a Robot from moving

var translucent:bool

func _init(id:int , texture_source_id:int , translucent:bool ):
	self.id = id
	self.translucent = translucent
	self.texture_source_id = texture_source_id

static func ROCK():
	return Obstacle.new(0, 3, false)

static func WATER():
	return Obstacle.new(1, 4,false)
	
func get_id():
	return self.id
	
func get_source_id():
	return self.texture_source_id
	
func is_translucent():
	return self.translucent
	
func set_translucent(new_translucent:bool):
	self.translucent = new_translucent
