class_name FarmItem
extends RefCounted

var texture_source_id:int
var id: int

func _init(id:int , texture_source_id:int):
	self.id = id
	self.texture_source_id = texture_source_id
	
func get_id():
	return self.id
	
func get_source_id():
	return self.texture_source_id

