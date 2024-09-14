extends GutTest

const MAIN = preload("res://scenes/main.tscn")
const TEST_SAVE_PATH = "user://code_game/test_save.save"
var main: Main
signal never

func before_all():
	LevelLoader.level_dir = "res://assets/levels/"
	PlayerSave.save_path = TEST_SAVE_PATH
	main = MAIN.instantiate()
	add_child(main)
	if not main.is_node_ready():
		await main.ready

func test_full_runthrough():
	assert_true(main.main_menu.visible)
	assert_false(main.level_select.visible)
	assert_false(main.level_node.visible)
	main.enter_state(Main.LEVEL_SELECT)
	assert_true(main.level_select.visible)
	assert_false(main.main_menu.visible)
	assert_false(main.level_node.visible)
	for id in range(1,11):
		var level_data = main.level_loader.get_level_data_by_id(id)
		assert_not_null(level_data)
		await run_level(id, level_data)
		await get_tree().process_frame

func run_level(id, level_data):
	var dev_solution = level_data.source_code
	assert_ne(dev_solution, "", "dev solution should not be empty")
	main._on_level_select_level_selected(id)
	assert_true(main.level_node.visible)
	assert_false(main.main_menu.visible)
	assert_false(main.level_select.visible)
	var code_edit = main.level_node.window.code_edit
	var level = main.level_node
	code_edit.clear()
	code_edit.start_action(TextEdit.ACTION_TYPING)
	for char in level_data.source_code:
		code_edit.insert_text_at_caret(char)
	code_edit.end_action()
	level.tick_rate = 50
	level.update_tick_rate()
	main.level_node._on_window_run_button_pressed()
	await wait_for_signal(level.victory, 30, "Level %d took too long to succeed with dev solution" % id)
	main.level_node._on_level_completed_next_level()
