extends GutTest

var level_loader: LevelLoader

var NO_TRANSLUCENTS = "no_translucents"
var TRANSLUCENTS = "translucents"

func before_all():
	LevelLoader.level_dir = "res://test/test_levels/randomization_testers/"
	level_loader = LevelLoader.new()
	add_child(level_loader)

func test_original_against_randomized():
	var result = level_loader.get_level_data_by_name(TRANSLUCENTS)
	var original_farm_model = result.get_farm_model()
	var randomized_farm_model = original_farm_model.randomized()
	
	assert_ne(original_farm_model.grid_map,randomized_farm_model.grid_map, "Grid maps should not be the same")
	
func test_no_translucents_no_randomize():
	var result = level_loader.get_level_data_by_name(NO_TRANSLUCENTS)
	var original_farm_model = result.get_farm_model()
	var randomized_farm_model = original_farm_model.randomized()
	
	assert_eq(original_farm_model.grid_map,randomized_farm_model.grid_map, "Grid maps should be the same")
#
func test_no_translucents_in_randomized():

	var result = level_loader.get_level_data_by_name(TRANSLUCENTS)
	var original_farm_model = result.get_farm_model()
	var randomized_farm_model = original_farm_model.randomized()
	
	for i in range(randomized_farm_model.width):
		for j in range(randomized_farm_model.height):
			var item = randomized_farm_model.get_item_at_coord(Vector2i(i,j))
			if item is Obstacle:
				print(item.is_translucent())
				assert_false(item.is_translucent(), "No translucent items should be in the farm model")
