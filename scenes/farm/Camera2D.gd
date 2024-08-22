extends Camera2D

var speed = 100
var zoom_margin = 0.3


var zoom_min =0.2
var zoom_max = 10

var zoom_pos  = Vector2()
var zoomfactor = 1.0



func _process(delta):
	zoom.x = lerp(zoom.x, zoom.x * zoomfactor, speed* delta)
	zoom.y = lerp(zoom.y, zoom.y * zoomfactor, speed* delta)
	
	zoom.x = clamp(zoom.x , zoom_min, zoom_max)
	zoom.y = clamp(zoom.y , zoom_min, zoom_max)
	

func _input(event):
	if abs(zoom_pos.x - get_global_mouse_position().x) > zoom_margin:
		zoomfactor = 1.0
	if abs(zoom_pos.y - get_global_mouse_position().y) > zoom_margin:
		zoomfactor = 1.0
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoomfactor -= 0.01
				zoom_pos = get_global_mouse_position()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoomfactor += 0.01
				zoom_pos = get_global_mouse_position()
