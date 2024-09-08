extends GutTest

var level_loader = null

const NON_EXISTENT = "res://test/test_levels/lvl_creation_testers/non_existent_file.txt"
const EMPTY_FILE = "res://test/test_levels/lvl_creation_testers/empty_file.txt"
const VALID_FARM = "res://test/test_levels/lvl_creation_testers/valid_farm.txt"
const INVALID_FARM = "res://test/test_levels/lvl_creation_testers/invalid_farm.txt"

func before_each():
	level_loader = load("res://scenes/level/level_loader.gd").new()
	add_child(level_loader)

func after_each():
	remove_child(level_loader)
	level_loader.queue_free()

func create_and_test_file(file_path: String, content: String, expected_result, message: String):
	create_file(file_path, content)
	var result = level_loader.create(file_path)
	assert_eq(result, expected_result, message)
	DirAccess.remove_absolute(file_path)

func create_file(file_path: String, content: String):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(content)
	file.close()

func test_non_existent_file():
	var result = level_loader.create(NON_EXISTENT)
	assert_eq(result, null, "Should return null for non-existent file")

func test_empty_file():
	create_and_test_file(EMPTY_FILE, "", null, "Should return null for empty file")

func test_valid_level():
		create_file(VALID_FARM, "#,r,s,#\n#,w,l,#\n#,#,#,#")
		var result = level_loader.create(VALID_FARM)
		assert_ne(result, null, "Should return a valid farm model for correct file")
		DirAccess.remove_absolute(VALID_FARM)

func test_invalid_levels():
	var invalid_layouts = [
		"#,r,s,#\n#,w,l,#",
		"#,r,s,#\n#,w,l,#\nw,#,#,#\n#,#,#,#",
		"#,r,s,#\n#,w,l,#\n#,#,#,w\n#,#,#,#",
		"#,w,l,#\n#,r,s,#",
		"#,w,l,#\n#,r"
	]
	
	for layout in invalid_layouts:
		create_and_test_file(INVALID_FARM, layout, null, "Should return null for invalid farm")

func test_original_against_randomized():
	create_file(VALID_FARM, "#,s,s,#\n#,l,l,#\n#,#,#,#")
	
	var result = level_loader.create(VALID_FARM)
	var result_compare = level_loader._randomize()
	
	assert_ne(result.grid_map, result_compare.grid_map, "Grid maps should not be the same")
	
	DirAccess.remove_absolute(VALID_FARM)

func test_no_translucents_not_randomized():
	create_file(VALID_FARM, "#,r,r,#\n#,w,w,#\n#,#,#,#")
	
	var result = level_loader.create(VALID_FARM)
	var result_compare = level_loader._randomize()
	
	assert_eq(result.grid_map, result_compare.grid_map, "Grid maps should be the same")
	
	DirAccess.remove_absolute(VALID_FARM)

func test_no_translucents_in_randomized():
	create_file(VALID_FARM, "#,r,r,#\n#,w,w,#\n#,#,#,#")
	
	var result = level_loader.create(VALID_FARM)
	result = level_loader._randomize()
	
	for j in range(result.height):
		for i in range(result.width):
			var item = result.get_item_at_coord(Vector2i(j,i))
			
			if item is Obstacle:
				assert_false(item.is_translucent(), "No translucent items should be in the farm model")
	
	DirAccess.remove_absolute(VALID_FARM)
