class_name Level
extends Node2D

@onready var window: CodeWindow = $Window
@onready var farm: FarmView = $Farm
@onready var interpreter_client: InterpreterClient = $InterpreterClient
@onready var level_completed = $CanvasLayer/LevelCompleted

@export var tick_rate = 4

var timer: Timer
var robot_wait_tick = 0
var score = 0
var count = 0
var goal_harvest:Dictionary

signal victory
signal failure

var width = 0
var height = 0

# TODO: make it so that an arbitrary farm goal and farm start state
# can be set

func check_victory():
	if(is_goal_harvest()):
			timer.stop()
			victory.emit()
			level_completed.show()
			window.hide()
			
func is_goal_harvest():
	#if farm.harvestables.size() != goal_harvest.size():
		#return false

	for key in goal_harvest:
		if not farm.harvestables.has(key):
			return false

		if farm.harvestables[key] < goal_harvest[key]:
			return false

	return true
	
func set_level(lvl_skeleton,goal_harvest):
	var lvl_skeleton_data = lvl_skeleton.get_as_text()
	
	var lvl_array = []
	var lines = lvl_skeleton_data.split("\n")
	
	for line in lines:
		if line != "":
			var items = line.split(",")
			lvl_array.append(items)
			width = len(items)
			height += 1

	var farm_model:FarmModel = FarmModel.new(width,height)
	
	for i in range(0,height):
		for j in range(0,width):
			var item = lvl_array[i][j]
			# # -> bare land
			# s -> transparent rock
			# r -> rock
			# l -> transparent water
			# w -> water
			## TODO: use some kind of enum to map symbol to obstacle name
			var coord: Vector2i = Vector2i(j, i)
			if item == "#":
				pass
			elif item == "s":
				var rock = Obstacle.ROCK()
				farm_model.add_obstacle(rock,coord)
			elif item == "r":
				var rock = Obstacle.ROCK()
				rock.set_transparency(255)
				farm_model.add_obstacle(rock,coord)
			elif item == "l":
				var water = Obstacle.WATER()
				farm_model.add_obstacle(water,coord)
			elif item == "w":
				var water = Obstacle.WATER()
				water.set_transparency(255)
				farm_model.add_obstacle(water,coord)
			
	farm.plot_farm(farm_model)
	
	self.goal_harvest = goal_harvest
	


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
	window.reset_console()
	
	if not interpreter_client.load_source(window.get_source_code()):
		return
	interpreter_client.start()
	# TODO: tick length zero => pause timer 
	var tick_length = 1.0/(float(tick_rate) + 0.00001)
	if is_instance_valid(timer) and timer.is_inside_tree():
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

func _on_interpreter_client_error(err: GError):
	window.set_error(err)

func _on_level_completed_next_level():
	pass


func _on_level_completed_retry():
	get_tree().reload_current_scene()
