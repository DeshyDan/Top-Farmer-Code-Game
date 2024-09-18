extends GutTest

@onready var level_scene:PackedScene = preload("res://scenes/level/level.tscn")

var level: Node
var farm_view:FarmView

const TICK_RATE = 30

const HARVEST_LEVEL = "res://test/test_levels/farm_view_testers/test_harvesting.txt"
const MOVE_LEVEL = "res://test/test_levels/farm_view_testers/test_robot_movement.txt"
const PLANT_LEVEL = "res://test/test_levels/farm_view_testers/test_planting.txt"

const MATURE_HARVEST_SCRIPT = "res://test/test_scripts/farm/harvest.txt"
const PREMATURE_HARVEST_SCRIPT = "res://test/test_scripts/farm/premature_harvest.txt"
const PLANT_SCRIPT = "res://test/test_scripts/farm/plant.txt"
const MOVE_SCRIPT = "res://test/test_scripts/farm/move.txt"

func before_all():
	level = level_scene.instantiate() as Level
	add_child(level)
	
func setup_level(level_skeleton_file_path:String,test_script:String):
	var farm_string = FileAccess.get_file_as_string(level_skeleton_file_path)
	var level_data = LevelData.new()
	level_data.farm_string = farm_string
	level_data.corn_goal = 4
	level_data.grape_goal = 4
	watch_signals(level.farm)
	level = level as Level
	level.initialize(level_data)
	var source = FileAccess.get_file_as_string(test_script)

	level.window.code_edit.text = source
	level.tick_rate = TICK_RATE 
	
func test_plant():
	setup_level(PLANT_LEVEL, PLANT_SCRIPT)
	
	level._on_window_run_button_pressed()

	assert_signal_emitted_with_parameters(level.farm,"plant_completed", [true],0)
	await yield_to(level.farm, "plant_completed",10)
	assert_signal_emitted_with_parameters(level.farm,"plant_completed", [false],1)

func test_premature_harvest():
	setup_level(HARVEST_LEVEL,PREMATURE_HARVEST_SCRIPT)

	level._on_window_run_button_pressed()
	
	await yield_to(level.farm, "harvest_completed",5)
	assert_signal_emitted_with_parameters(level.farm,"harvest_completed", [false],0)
	
func test_mature_harvest():
	setup_level(HARVEST_LEVEL, MATURE_HARVEST_SCRIPT)

	level._on_window_run_button_pressed()
	
	await yield_to(level.farm, "harvest_completed",15)
	assert_signal_emitted_with_parameters(level.farm,"harvest_completed", [true],0)

func test_move():
	setup_level(MOVE_LEVEL, MOVE_SCRIPT)

	level._on_window_run_button_pressed()
	
	if not await wait_for_signal(level.interpreter_client.finished, 15):
		fail_test("Interpreter took too long")

	#can hover over water but not rocks and is bounded by edge
	# CHECK MOVE LEVEL FOR MORE CLARITY
	# FARMERS MOVEMENTS: [UP, LEFT, DOWN, DOWN,RIGHT,RIGHT, UP, RIGHT]
	assert_signal_emitted_with_parameters(level.farm,"move_completed", [false],0) # UP | OUT OF BOUNDS
	assert_signal_emitted_with_parameters(level.farm,"move_completed", [false],1) # LEFT | OUT OF BOUNDS
	assert_signal_emitted_with_parameters(level.farm,"move_completed", [true],2) # DOWN | LAND
	assert_signal_emitted_with_parameters(level.farm,"move_completed", [false],3) # DOWN |OUT OF BOUNDS
	assert_signal_emitted_with_parameters(level.farm,"move_completed", [true],4) # RIGHT | LAND
	assert_signal_emitted_with_parameters(level.farm,"move_completed", [true],5) # RIGHT |WATER
	assert_signal_emitted_with_parameters(level.farm,"move_completed", [false],6) # UP | ROCK 
	assert_signal_emitted_with_parameters(level.farm,"move_completed", [true],7) # RIGHT | lAND
	assert_signal_emitted_with_parameters(level.farm,"move_completed", [false],8) # RIGHT | OUT OF BOUNDS

func test_harvestables():
	setup_level(PLANT_LEVEL, MATURE_HARVEST_SCRIPT)

	assert_eq(level.farm.get_harvestables(), {})
	
	level._on_window_run_button_pressed()
	
	if not await wait_for_signal(level.interpreter_client.finished, 15):
		fail_test("Interpreter took too long")

	
	for i in level.farm.get_harvestables():
		match i:
			Const.PlantType.PLANT_CORN:
				assert_true(level.farm.get_harvestables()[i] == 2)
			Const.PlantType.PLANT_GRAPE:
				assert_true(level.farm.get_harvestables()[i] == 2)
	
func test_reset():
	setup_level(PLANT_LEVEL, MATURE_HARVEST_SCRIPT)

	level._on_window_run_button_pressed()
	
	if not await wait_for_signal(level.interpreter_client.finished, 15):
		fail_test("Interpreter took too long")
	
	var source = FileAccess.get_file_as_string("")
	level.window.code_edit.text = source
	level._on_window_run_button_pressed()
	
	assert_eq(level.farm.get_harvestables(), {})

	for i in level.farm.farm_model.get_data():
		assert_true((i is Obstacle) or (i.is_empty()))

	
