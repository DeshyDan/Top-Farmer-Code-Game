class_name Obstacle
extends FarmItem

var transparency: int

func _init(id:int , texture_source_id:int , transparency:int ):
	self.id = id
	self.transparency = transparency
	self.texture_source_id = texture_source_id

static func ROCK():
	return Obstacle.new(0, 3, 127)

static func WATER():
	return Obstacle.new(1, 4, 127)
	
func get_id():
	return self.id
	
func get_source_id():
	return self.texture_source_id
	
func get_transparency():
	return self.transparency
	
func set_transparency(new_transparency:int):
	self.transparency = new_transparency
