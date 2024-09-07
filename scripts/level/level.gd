class_name Level
extends Node2D

@export var window: CodeWindow
@export var farm: FarmView
@export var interpreter_client: InterpreterClient
@export var level_completed: Node

@export var tick_rate = 4

@onready var score_label = $CanvasLayer/Score
@onready var camera = $camera

var timer: Timer
var robot_wait_tick = 0
var score = 0
var count = 0
var level = 0
var paused = false
var lvl_array
var farm_model:FarmModel
var level_loader: LevelLoader
var original_farm_model:FarmModel

var goal_harvest:Dictionary

signal victory
signal failure

var width = 0
var height = 0

var player_save: PlayerSave
# TODO: make it so that an arbitrary farm goal and farm start state
# can be set

func set_player_save(save: PlayerSave):
	player_save = save

func set_source_code(source: String):
	window.code_edit.text = source

func check_victory():
	if(is_goal_harvest()):
		timer.stop()
		victory.emit()
		level_completed.show()
		window.hide()
			
func is_goal_harvest():
	if farm.harvestables.size() != goal_harvest.size():
		return false

	for key in goal_harvest:
		if not farm.harvestables.has(key):
			return false

		if farm.harvestables[key] < goal_harvest[key]:
			return false

	return true
	
func set_level(lvl_skeleton,goal_harvest,level):
	self.level = level
	
	var lvl_skeleton_data = lvl_skeleton.get_as_text()
	
	level_loader = LevelLoader.new()
	add_child(level_loader)
	
	lvl_array = level_loader.create(lvl_skeleton_data)
	
	original_farm_model = _create_farm_model(lvl_array)
	
	self.goal_harvest = goal_harvest
	camera.fit_zoom_to_farm(farm)

func _create_farm_model(data:Dictionary):

	farm_model = FarmModel.new(data["width"],data["height"])
	var array = data["FarmArray"]
	
	for i in range(0,data["height"]):
		for j in range(0,data["width"]):
			var item = array[i][j]
			var coord: Vector2i = Vector2i(j, i)
			if item == null:
				pass
			else:
				farm_model.add_farm_item(item,coord)
			
	farm.plot_farm(farm_model)
	self.goal_harvest = goal_harvest
	camera.fit_zoom_to_farm(farm)
	
	return farm_model
	
func _randomize(data:Dictionary):
		var transformed_data = []
		var rock_candidates = []
		var water_row_candidates = []
		
		var default_value = null
		for y in range(data["height"]):
			var row = []
			for x in range(data["width"]):
				row.append(default_value)
			transformed_data.append(row)
	
  
		for i in range(data["FarmArray"].size()):
			for j in range(data["FarmArray"][i].size()):
				var item = data["FarmArray"][i][j]
				if item == null: 
					continue
				if item.get_id() == 0 and item.is_translucent():
					rock_candidates.append([i,j])
				elif item.get_id() == 1 and item.is_translucent():
					if j == 0:
						water_row_candidates.append(i)
	

		for i in range(min(2, rock_candidates.size())):
			if rock_candidates.size() > 0:
				var index = randi() % rock_candidates.size()
				var rock_index = rock_candidates[index]
				transformed_data[rock_index[0]][rock_index[1]] = Obstacle.ROCK()
				rock_candidates.pop_at(index)
	
   
		if water_row_candidates.size() > 0:
			var row = water_row_candidates.pick_random()
			
			for i in range(data["FarmArray"].size()):
				for j in range(data["FarmArray"][i].size()):
					if i == row:
						transformed_data[i][j] = Obstacle.WATER()
			
	
		_create_farm_model({"FarmArray": transformed_data,
		"width":data["width"],
		"height":data["height"]})

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

	if level == 3 and paused == false:
		_randomize(lvl_array)

	if player_save:
		player_save.update_level_source(3, window.get_source_code())
	
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
	pass


func _on_level_completed_retry():
	get_tree().reload_current_scene()


func _on_window_ui_exec_speed_changed(value):
	tick_rate = value
	update_tick_rate()


func _on_farm_move_completed(successful):
	pass # Replace with function body.


func _on_farm_harvest_completed(successful):
	pass # Replace with function body.


func _on_farm_plant_completed(successful):
	pass # Replace with function body.
