class_name Level
extends Node2D
@onready var window: CodeWindow = $Window
@onready var farm: FarmView = $Farm
@onready var interpreter_client: InterpreterClient = $InterpreterClient
@onready var level_completed = $CanvasLayer/LevelCompleted

var timer: Timer
var victory_crop:int = 0
var robot_wait_tick = 0

@export var tick_rate = 4

signal victory
signal failure

# TODO: make it so that an arbitrary farm goal and farm start state
# can be set

func check_victory():
	if farm.harvestables.size() >= 1:
		if farm.harvestables[0] >= victory_crop:
			timer.stop()
			victory.emit()
			level_completed.show()
			window.hide()
			
			
func set_level(width,height,victory_crop_quantity):
	farm.plot_farm(width,height)
	victory_crop = victory_crop_quantity
	
	
var score = 0
var count = 0

func add_points():
	# Increase the score by a certain number of points
	count += 1
	score = 1000/count
	update_score()

func update_score():
	# Access the Score Label node and update its text
	var score_label = $Score
	score_label.text = "Score: " + str(score)
	
func reset_score():
	# Access the Score Label node and update its text
	score = 1000
	var score_label = $Score
	score_label.text = "Score: " + str(score)
	

# TODO: test that this scene can be instantiated from anywhere without
# breaking

# TODO: make it so that a tracepoint from the interpreter can wait n ticks
# before continuing

# TODO: keep track of the players score

func _on_window_run_button_pressed():
	# TODO: clear window.console
	if not interpreter_client.load_source(window.get_source_code()):
		return
	interpreter_client.start()
	# TODO: tick length zero => pause timer 
	var tick_length = 1.0/(float(tick_rate) + 0.00001)
	if timer and timer.is_inside_tree():
		remove_child(timer)
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_tick)
	timer.start(tick_length)

func _on_window_pause_button_pressed():
	if not timer:
		return
	timer.paused = not timer.paused

func _on_window_kill_button_pressed():
	if timer and timer.is_inside_tree():
		remove_child(timer)
	interpreter_client.kill()
	farm.reset()
	reset_score()

func _on_timer_tick():
	# TODO: check for victory here
	farm.tick()
	add_points()
	check_victory()
	if robot_wait_tick > 0:
		robot_wait_tick -= 1
		return
	interpreter_client.tick()

func _on_print_call(args: Array):
	window.print_to_console(" ".join(args))

func _on_move_call(args: Array):
	farm.move(args[0])

func _on_plant_call(args: Array):
	farm.plant(args[0])

func _on_harvest_call(args: Array):
	farm.harvest()

func _on_wait_call(args: Array):
	robot_wait_tick = 5
	farm.wait()

# the interpreter client has reached a line, we should highlight it
func _on_tracepoint_reached(node: AST, call_stack: CallStack):
	window.highlight_tracepoint.bind(node, call_stack).call_deferred()

func _on_interpreter_client_finished():
	print("INTERPRETER FINISHED")
	if is_instance_valid(timer):
		timer.queue_free()
	# TODO: show failure screen here
	failure.emit()

func _on_interpreter_client_error(message):
	window.print_to_console(message)


func _on_level_completed_next_level():
	pass


func _on_level_completed_retry():
	get_tree().reload_current_scene()
