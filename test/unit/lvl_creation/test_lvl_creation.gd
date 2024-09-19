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
	assert_eq(farm_model.get_width(), 0, "Should return empty farm")
	assert_eq(farm_model.get_height(), 0, "Should return empty farm")
	
func test_valid_level():
	var result = level_loader.get_level_data_by_name(VALID_FARM)
	assert_not_null(result, "Should return valid level data for correct file")

func test_invalid_level():
	pass
