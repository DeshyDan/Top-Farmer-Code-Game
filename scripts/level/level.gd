class_name Level
extends Node2D

signal level_complete
signal retry_requested

@export var window: CodeWindow
@export var farm: FarmView
@export var interpreter_client: InterpreterClient
@export var level_completed: Node

@export var tick_rate = 4

@onready var score_label = $CanvasLayer/Score
@onready var camera = $camera

var id: int
var timer: Timer
var robot_wait_tick = 0
var score = 0
var count = 0
var paused = false
var farm_model:FarmModel
var level_loader: LevelLoader
var first_lvl

var goal_state:Dictionary

signal victory
signal failure

var width = 0
var height = 0

var player_save: PlayerSave

func _ready():
	camera.make_current()

func set_player_save(save: PlayerSave):
	player_save = save
	
func set_source_code(source: String):
	window.code_edit.text = source
	window.code_edit.clear_undo_history()

func check_victory():
	if first_lvl:
		pass
	elif (is_goal_state()):
		timer.stop()
		victory.emit()
		level_completed.show()
		window.hide()

func is_goal_state():
	for key in goal_state:
		if goal_state[key] != 0:
			if not farm.harvestables.has(key) or farm.harvestables[key] < goal_state[key]:
				return false
	return true
	
func set_level(level_script, goal_state):
	level_loader = LevelLoader.new()
	add_child(level_loader)

	farm_model = level_loader.create(level_script)

	first_lvl = farm_model._find_goal()
	
	farm.plot_farm(farm_model)
	farm.set_goal_state(goal_state)
	camera.fit_zoom_to_farm(farm)
	
	self.goal_state = goal_state
	
	

func add_points():
	# Increase the score by a certain number of points
	count += 1
	score = 1000/count
	update_score()

func update_score():
	# Access the Score Label node and update its text
	score_label.text = "Score: " + str(score)
	
func reset_score():
	# Access the Score Label node and update its text
	score = 1000
	count = 0
	score_label.text = "Score: " + str(score)

func update_tick_rate():
	var tick_length = 1.0/(float(tick_rate) + 0.00001)
	if is_instance_valid(timer) and timer.is_inside_tree():
		timer.stop()
		if tick_rate == 0:
			return
		timer.start(tick_length)

func _on_window_run_button_pressed():
	window.reset_console()
	farm.reset()
	reset_score()

	farm_model = level_loader._randomize()
	farm.plot_farm(farm_model)
	camera.fit_zoom_to_farm(farm)

	if player_save:
		player_save.update_level_source(id, window.get_source_code())
	
	interpreter_client.kill()
	if not interpreter_client.load_source(window.get_source_code()):
		return
	interpreter_client.start()
	var tick_length = 1.0/(float(tick_rate) + 0.00001)
	if is_instance_valid(timer) and timer.is_inside_tree():
		remove_child(timer)
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_tick)
	timer.start(tick_length)

func _on_window_pause_button_pressed():
	if not is_instance_valid(timer):
		return
	paused = true
	timer.paused = not timer.paused

func _on_window_kill_button_pressed():
	if is_instance_valid(timer) and timer.is_inside_tree():
		remove_child(timer)
	interpreter_client.kill()
	reset_score()
	paused = false
	farm.reset()
	

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
	window.highlight_tracepoint.call_deferred(node, call_stack)

func _on_interpreter_client_finished():
	print("INTERPRETER FINISHED")
	if is_instance_valid(timer):
		timer.queue_free()
	# TODO: show failure screen here
	failure.emit()

func _on_interpreter_client_error(err: GError):
	window.set_error(err)
	farm.robot.error()

func _on_level_completed_next_level():
	level_complete.emit()

func _on_level_completed_retry():
	retry_requested.emit()


func _on_window_ui_exec_speed_changed(value):
	tick_rate = value
	update_tick_rate()


func _on_farm_move_completed(successful):
	interpreter_client.input.call_deferred(successful)


func _on_farm_harvest_completed(successful):
	interpreter_client.input.call_deferred(successful)


func _on_farm_plant_completed(successful):
	interpreter_client.input.call_deferred(successful)


func _on_farm_goal_pos_met():
	if is_instance_valid(timer):
		timer.stop()
	victory.emit()
	level_completed.show()
	window.hide()
