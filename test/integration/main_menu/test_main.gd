extends GutTest


@onready var main_scene:PackedScene = preload("res://scenes/main.tscn")

const TEST_LEVELS_PATH = "res://test/test_levels/runthrough_testers/"
var main:Node

func before_all():
	main = main_scene.instantiate() as Main
	#LevelLoader.level_dir = TEST_LEVELS_PATH
	#var level_loader = LevelLoader.new()
	add_child(main)
	#var def_loader = main.get_node("LevelLoader")
	#def_loader.level_dir = TEST_LEVELS_PATH
	#main.remove_child(def_loader)
	#main.add_child(level_loader)
	#main.level_loader = level_loader
	
	
	


func test_load_main_screen():
	assert_true(main.main_menu.visible)
	
	assert_false(main.level_select.visible)
	assert_false(main.level_node.visible)

func test_load_level_select_screen_from_main():
	main.main_menu._on_play_button_pressed()
	
	assert_false(main.main_menu.visible)
	assert_true(main.level_select.visible)
	assert_false(main.level_node.visible)
	
	## Optimistic approach -> There will always be a level. It a game after all...actaully don't know what I'm doing LOL
	assert_true(main.level_select.level_buttons.get_child_count() == 10)
	
