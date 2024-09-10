extends GutTest

var level_loader = null 

var NON_EXISTENT = "res://test/test_levels/lvl_creation_testers/non_existent_file.txt"
var EMPTY_FILE = "res://test/test_levels/lvl_creation_testers/empty_file.txt"
var VALID_FARM = "res://test/test_levels/lvl_creation_testers/valid_farm.txt"
var NO_TRANSLUCENTS = "res://test/test_levels/lvl_creation_testers/no_translucents.txt"
var INVALID_FARM = "res://test/test_levels/lvl_creation_testers/invalid_farm_"

func before_each():
	level_loader = load("res://scenes/level/level_loader.gd").new()
	add_child(level_loader)

func test_non_existent_file():
	var result = level_loader.create(NON_EXISTENT)
	assert_eq(result, null, "Should return null for non-existent file")

func test_empty_file():
	var result = level_loader.create(EMPTY_FILE)
	assert_eq(result, null, "Should return null for invalid farm")
	
func test_valid_level():
	var result = level_loader.create(VALID_FARM)
	assert_not_null(result, "Should return a valid farm model for correct file")
	
func test_invalid_level():
	for i in range(1,5):
		var file_path = INVALID_FARM+str(i)+".txt"
		var result = level_loader.create(INVALID_FARM)
		assert_eq(result, null, "Should return null for invalid farm")
		
	
func test_original_against_randomized():
	var result = level_loader.create(VALID_FARM)
	var result_compare = level_loader._randomize()
	
	assert_ne(result.grid_map,result_compare.grid_map, "Grid maps should not be the same")
	
func test_no_translucents_no_randomize():
	var result = level_loader.create(NO_TRANSLUCENTS)
	var result_compare = level_loader._randomize()
	
	assert_eq(result.grid_map,result_compare.grid_map, "Grid maps should be the same")

func test_no_translucents_in_randomized():

	var result = level_loader.create(VALID_FARM)
	result = level_loader._randomize()
	
	for j in range(result.height):
		for i in range(result.width):
			var item = result.get_item_at_coord(Vector2i(j,i))
			
			if item is Obstacle:
				assert_false(item.is_translucent(), "No translucent items should be in the farm model")
