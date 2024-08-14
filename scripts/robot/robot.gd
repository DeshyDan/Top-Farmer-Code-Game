class_name Robot
extends CharacterBody2D

var robot_tile_coords:Vector2i = Vector2i(0,0)
@onready var animated_sprite = $AnimatedSprite2D
enum Direction {
	NORTH,
	SOUTH, 
	EAST,
	WEST 
}

func move(dir:Direction):
	var vec: Vector2i
	match dir:
		Direction.NORTH:
			vec = Vector2i.UP
			change_direction(vec)
		Direction.SOUTH:
			vec = Vector2i.DOWN
			change_direction(vec)
		Direction.EAST:
			vec = Vector2i.RIGHT
			change_direction(vec)
		Direction.WEST:
			vec = Vector2i.LEFT
			change_direction(vec)
	
	self.robot_tile_coords += vec
	return robot_tile_coords
	
func change_direction(vec:Vector2i):
	position.x += vec.x  *16
	position.y += vec.y*16
	
func plant():
	animated_sprite.play("planting")
	await get_tree().create_timer(0.2).timeout
	animated_sprite.play("idle")
	
func harvest():
	animated_sprite.play("harvesting")
	await get_tree().create_timer(0.2).timeout
	animated_sprite.play("idle")
	
func get_coords():
	return robot_tile_coords
func set_coords(coords:Vector2i):
	robot_tile_coords = coords
func _process(delta):
	pass
