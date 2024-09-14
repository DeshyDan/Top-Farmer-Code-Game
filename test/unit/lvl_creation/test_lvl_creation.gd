extends GutTest

var level_loader: LevelLoader

var NON_EXISTENT = "non_existent"
var EMPTY_FILE = "empty_level"
var VALID_FARM = "valid_level"
var NO_TRANSLUCENTS = "no_translucents"

func before_all():
	LevelLoader.level_dir = "res://test/test_levels/lvl_creation_testers/"
	level_loader = LevelLoader.new()
	add_child(level_loader)
	

func test_non_existent_file():
	var result = level_loader.get_level_data_by_name(NON_EXISTENT)
	assert_eq(result, null, "Should return null for non-existent file")

func test_empty_file():
	var result = level_loader.get_level_data_by_name(EMPTY_FILE)
	var farm_model = result.get_farm_model()
	assert_eq(farm_model.width, 0, "Should return empty farm")
	assert_eq(farm_model.height, 0, "Should return empty farm")
	
func test_valid_level():
	var result = level_loader.get_level_data_by_name(VALID_FARM)
	assert_not_null(result, "Should return valid level data for correct file")

func test_invalid_level():
	pass
	#
#func test_original_against_randomized():
	#var result = level_loader.create(VALID_FARM)
	#var result_compare = level_loader._randomize()
	#
	#assert_ne(result.grid_map,result_compare.grid_map, "Grid maps should not be the same")
	#
#func test_no_translucents_no_randomize():
	#var result = level_loader.create(NO_TRANSLUCENTS)
	#var result_compare = level_loader._randomize()
	#
	#assert_eq(result.grid_map,result_compare.grid_map, "Grid maps should be the same")
#
#func test_no_translucents_in_randomized():
#
	#var result = level_loader.create(VALID_FARM)
	#result = level_loader._randomize()
	#
	#for j in range(result.height):
		#for i in range(result.width):
			#var item = result.get_item_at_coord(Vector2i(j,i))
			#
			#if item is Obstacle:
				#assert_false(item.is_translucent(), "No translucent items should be in the farm model")
