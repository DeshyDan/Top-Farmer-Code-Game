extends GutTest


@onready var main_scene:PackedScene = preload("res://scenes/main.tscn")

var main:Node

func before_each():
	main = main_scene.instantiate() 
	add_child(main)
	
func after_each():
	remove_child(main)
	main.free()
	
func test_load_main_screen():
	assert_true(main.main_menu.visible)
	
	assert_false(main.level_select.visible)
	assert_false(main.level_node.visible)

func test_load_level_select_screen_from_main():
	main.main_menu._on_play_button_pressed()
	
	assert_false(main.main_menu.visible)
	assert_true(main.level_select.visible)
	assert_false(main.level_node.visible)
	
	## Optimistic approach -> There are always 10 level :p
	assert_eq(main.level_select.level_buttons.get_child_count(),10)

#func test_load_level_select_screen_from_levels():
	#main.main_menu._on_play_button_pressed()
	#
	#watch_signals(main.level_node)
	#for i in range(1, main.level_select.level_buttons.get_child_count()):
#
		#main._on_level_select_level_selected(i)
		#main.level_node._on_back_button_pressed()
		#
		#await yield_to(main.level_node, "exit_requested", 1)
		#
		#assert_signal_emitted(main.level_node ,"exit_requested")

func test_progress_through_all_levels():
	main.main_menu._on_play_button_pressed()
	watch_signals(main.level_node)
	
	for i in range(1, main.level_select.level_buttons.get_child_count()+1):
		main._on_level_select_level_selected(i)
		assert_eq(i, main.level_node.id)
		
		run_solution(i)
		
		if not await wait_for_signal(main.level_node.victory, 30):
			fail_test("Interpreter took too long")
		
		assert_signal_emitted(main.level_node, "victory")
		main.level_node._on_level_completed_next_level()
		
		if (i >= main.level_select.level_buttons.get_child_count()+1):
			assert_true(main.main_menu.visible)
			assert_false(main.level_select.visible)
			assert_false(main.level_node.visible)
			
		assert_signal_emitted(main.level_node , "next_level_requested")
		
		
func run_solution(level_id):
	var level_data = main.level_loader.get_level_data_by_id(level_id)
	main.level_node.window.code_edit.text = level_data.source_code
	main.level_node.window._on_exec_speed_slider_value_changed(100)
	main.level_node._on_window_run_button_pressed()
