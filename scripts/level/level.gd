class_name Level
extends Node2D
# Class acts as a coordinator between the modules
# It provides the functionality of accepting requests from CodeWindow and InterpreterClient and
# providing the necessary responses

signal next_level_requested
signal retry_requested
signal exit_requested

signal victory
signal failure

@export var window: CodeWindow
@export var farm: FarmView
@export var interpreter_client: InterpreterClient
@export var level_completed: Node
@export var ui_canvas_layer: CanvasLayer
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

var goal_state:Dictionary

var width = 0
var height = 0

var player_save: PlayerSave = PlayerSave.new()

func initialize(level_data: LevelData):
	id = level_data.id
	player_save.load_progress()
	set_player_save(player_save)
	window.initialize(level_data, player_save.get_level_source(id))
	window.show()
	farm_model = level_data.get_farm_model()
	goal_state = level_data.get_goal_state()
	farm.set_original_farm_model(level_data.get_farm_model()) # call get_farm_model again to avoid shared references
	farm.plot_farm(farm_model)
	farm.set_goal_state(goal_state)
	camera.fit_zoom_to_farm(farm)
	camera.make_current()
	reset()

func reset():
	level_completed.hide()
	farm.clear_farm()
	farm.reset()

func set_player_save(save: PlayerSave):
	player_save = save
	
func check_victory():
	if (is_goal_state()):
		timer.stop()
		victory.emit()
		level_completed.show()
		window.hide()

func is_goal_state():
	if farm_model.goal_pos:
		return farm_model.goal_pos == farm.robot_tile_coords
	for key in goal_state:
		if goal_state[key] != 0:
			if not farm.harvestables.has(key) or farm.harvestables[key] < goal_state[key]:
				return false
	return true

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

	farm.plot_farm(farm_model.randomized())
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
	next_level_requested.emit()

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


func _on_back_button_pressed():
	if is_instance_valid(timer):
		timer.queue_free()
	exit_requested.emit()


func _on_visibility_changed():
	if not is_node_ready():
		await ready

	for level_ui_layer in get_tree().get_nodes_in_group("level_ui_layers"):
		level_ui_layer.visible = visible
	
