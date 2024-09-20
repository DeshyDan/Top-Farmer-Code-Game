class_name Robot
extends Node2D
# Class represents a robot used to perfom farming actions in the farm.
# It also handles the logic related to movement and animations

const _STEP_MAX = 99999999

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var _x_max_boundary :int
var _y_max_boundary :int
var _robot_tile_coords:Vector2i = Vector2i(0,0)
var _move_tween: Tween

func move(vec:Vector2i):
	change_direction(vec)
	self._robot_tile_coords += vec
	return _robot_tile_coords
	
func change_direction(vec:Vector2i):
	animated_sprite.flip_h = false
	if _move_tween:
		_move_tween.custom_step(_STEP_MAX)	# skip to target if too slow for now
	match vec:
		Vector2i.UP:
			animated_sprite.play("move_up")
		Vector2i.DOWN:
			animated_sprite.play("move_down")
		Vector2i.LEFT:
			animated_sprite.play("move_sideways")
			animated_sprite.flip_h = true
		Vector2i.RIGHT:
			animated_sprite.play("move_sideways")
	animated_sprite.animation_finished.connect(
		func():
			animated_sprite.play("idle")
	)
	var target = position + Vector2(vec * 16)
	_move_tween = create_tween()
	_move_tween.tween_method(_move, position, target, 0.2).set_trans(Tween.TRANS_CUBIC)
	_move_tween.tween_callback(_move.bind(target))

func _move(pos: Vector2):
	position = pos

func plant():
	animated_sprite.play("planting")
	await get_tree().create_timer(0.2).timeout
	animated_sprite.play("idle")
	
func harvest():
	animated_sprite.play("harvesting")
	await get_tree().create_timer(0.2).timeout
	animated_sprite.play("idle")

func wait():
	animated_sprite.play("wait")
	await get_tree().create_timer(0.4).timeout
	animated_sprite.play("idle")

func idle():
	animated_sprite.play("idle")

func error():
	animated_sprite.play("fright")
	animated_sprite.animation_finished.connect(
		func(): animated_sprite.play("error_idle")
	)

func get_coords():
	return _robot_tile_coords

func set_coords(coords:Vector2i):
	_robot_tile_coords = coords

func set_boundaries(width:int , height:int):
	_x_max_boundary = width
	_y_max_boundary = height

func reset():
	if _move_tween:
		_move_tween.kill()
