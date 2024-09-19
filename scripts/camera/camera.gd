extends Camera2D
# This class is used to only show the area covered by the camera in the viewport.
# It provides functionality like zooming and panning into an in the game  

const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 12.0
const ZOOM_RATE: float = 8.0
const ZOOM_INCREMENT: float = 0.1

var _target_zoom: float = 1.0

@onready var tween: Tween 

var _dragging = false
var _prev_position = Vector2.ONE

func _ready():
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	zoom = lerp(zoom, _target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	var new_mouse_pos = get_global_mouse_position()
	set_physics_process(not is_equal_approx(zoom.x, _target_zoom))
	position += mouse_pos - new_mouse_pos
	reset_smoothing()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_in()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_out()
		
		if event.button_index in [MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_LEFT]:
			if event.is_pressed():
				_prev_position = event.position
				_dragging = true
			else:
				_dragging = false

	elif event is InputEventMouseMotion && _dragging:
		position += (_prev_position - event.position) / zoom
		_prev_position = event.position

	elif event is InputEventMagnifyGesture:
		zoom *= event.factor

func fit_zoom_to_farm(farm: FarmView):
	# Adjust the camera zoom relative to the farm dimension
	#TODO: use nice api
	var farm_width = farm.farm_tilemap.tile_set.tile_size.x * farm.farm_model.get_width() * farm.farm_tilemap.global_scale.x
	var viewport_width = get_viewport_rect().size.x
	var target_relative_size = 0.4
	var relative_size = farm_width / viewport_width
	var zoom_factor = (target_relative_size / relative_size) / 1.5
	position = Vector2(farm.position.x - farm_width / 4, farm.position.y + farm_width / 4)
	reset_smoothing()
	zoom_factor = max(zoom_factor, MIN_ZOOM)
	zoom_factor = min(zoom_factor, MAX_ZOOM)
	zoom = zoom_factor * Vector2.ONE
	_target_zoom = zoom_factor

func _zoom_in() -> void:
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)
	
func _zoom_out() -> void:
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	set_physics_process(true)


