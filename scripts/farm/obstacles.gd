class_name Obstacle
extends FarmItem

var visibility:String

func _init(id:int , texture_source_id:int , visibility:String ):
	self.id = id
	self.visibility = visibility
	self.texture_source_id = texture_source_id

static func ROCK():
	return Obstacle.new(0, 3, "#ffffff")

static func WATER():
	return Obstacle.new(1, 4,"#ffffff")
	
func get_id():
	return self.id
	
func get_source_id():
	return self.texture_source_id
	
func get_visibility():
	return self.visibility
	
func set_visibility(new_visibility:String):
	self.visibility = new_visibility
