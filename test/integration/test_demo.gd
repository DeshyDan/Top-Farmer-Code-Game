extends GutTest

@onready var level_scene:PackedScene = preload("res://scenes/level/level.tscn")
var lvl: Node
var tick_count_optimized=0
var tick_count_unoptimized=0
# Called when the node enters the scene tree for the first time.
func before_each():
	# Instantiate the loaded scene
	lvl = level_scene.instantiate() as Level
	add_child(lvl)
	
	var level_data = load("res://test/test_levels/demo_lvl.tres")
	
	lvl.initialize(level_data)

func test_demo_unoptimized():
	lvl = lvl as Level
	var source = FileAccess.get_file_as_string("res://test/test_scripts/demo/demo_unoptimized.txt")
	lvl.window.code_edit.text = source
	lvl.tick_rate = 10
	lvl._on_window_run_button_pressed()
	lvl.timer.timeout.connect(func(): tick_count_unoptimized += 1)
	if not await wait_for_signal(lvl.victory, 15.0):
		fail_test("level took too long")
	assert_true(lvl.farm.inventory.corn_quantity.text == "4")
	

func test_demo_optimized():
	lvl = lvl as Level
	var source = FileAccess.get_file_as_string("res://test/test_scripts/demo/demo_optimized.txt")
	lvl.window.code_edit.text = source
	lvl.tick_rate = 10
	lvl._on_window_run_button_pressed()
	lvl.timer.timeout.connect(func(): tick_count_optimized += 1)
	if not await wait_for_signal(lvl.victory, 15.0):
		fail_test("level took too long")
	assert_true(lvl.farm.inventory.corn_quantity.text == "4")

func after_each():
	remove_child(lvl)
	lvl.free()
	

func after_all():
	print(tick_count_optimized)
	print(tick_count_unoptimized)
	assert_lt(tick_count_optimized, tick_count_unoptimized)
