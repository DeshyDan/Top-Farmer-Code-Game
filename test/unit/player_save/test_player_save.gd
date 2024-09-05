extends GutTest

var player_save: PlayerSave
var default_player_save: PlayerSave
const TEST_SAVE_PATH = "user://code_game/test_save_path.save"
const TEST_SAVE_DIR = "user://code_game/"
const TEST_SAVE_FILE = "test_save_path.save"

func before_all():
	PlayerSave.save_path = TEST_SAVE_PATH
	var default_player_save = PlayerSave.new()
	default_player_save.load_progress()

	var dir = DirAccess.open(TEST_SAVE_DIR)
	if dir == null:
		fail_test("Unable to open user://save")
		return
	if dir.file_exists(TEST_SAVE_FILE):
		var result = dir.remove(TEST_SAVE_FILE)
		assert_eq(result, OK, "Unable to remove test save file")
	
	var default_level = PlayerSave.DEFAULT_LEVEL
	assert_eq(default_player_save.get_level_source(default_level), "", "Expected empty source")
	assert_eq(default_player_save.get_level_high_score(default_level), null, "Expected no high score")
	assert_eq_deep(default_player_save._unlocked_levels, [default_level])

func before_each():
	player_save = PlayerSave.new()

func test_empty_file():
	var save = FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	assert_not_null(save, "Unable to open save file")
	save.store_line("")
	save.close()
	player_save.load_progress()
	assert_not_null(player_save, "Failed on empty save file")
	assert_not_null(player_save._level_high_scores)
	assert_not_null(player_save._unlocked_levels)
	assert_not_null(player_save._source_codes)

func test_gibberish_file():
	var save = FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	assert_not_null(save, "Unable to open save file")
	save.store_line("ui-094287g4189g-354jhiulghr14buvpJKEKN")
	save.close()
	player_save.load_progress()
	assert_not_null(player_save, "Failed on empty save file")
	assert_not_null(player_save._level_high_scores)
	assert_not_null(player_save._unlocked_levels)
	assert_not_null(player_save._source_codes)

func test_no_file():
	var dir = DirAccess.open(TEST_SAVE_DIR)
	if dir == null:
		fail_test("Unable to open user://save")
		return
	if dir.file_exists(TEST_SAVE_FILE):
		var result = dir.remove(TEST_SAVE_FILE)
		assert_eq(result, OK, "Unable to remove test save file")
	else:
		fail_test("test save file not found")
	player_save.load_progress()
	var default_level = PlayerSave.DEFAULT_LEVEL
	assert_eq(player_save.get_level_source(default_level), "", "Expected empty source")
	assert_eq(player_save.get_level_high_score(default_level), null, "Expected no high score")
	assert_eq_deep(player_save._unlocked_levels, [default_level])
	assert_eq(player_save._level_high_scores, {})
	assert_eq(player_save._source_codes, {str(default_level) : ""})

func test_unlock_level():
	player_save.load_progress()
	player_save.unlock_level(1)
	player_save = null
	player_save = PlayerSave.new()
	player_save.load_progress()
	var unlocked_lvls = player_save._unlocked_levels
	var has_lvl = false
	for lvl in unlocked_lvls:
		if lvl == 1:
			has_lvl = true
	assert_true(has_lvl)

func test_source_save():
	player_save.load_progress()
	player_save.update_level_source(player_save.DEFAULT_LEVEL, "test")
	player_save = null
	player_save = PlayerSave.new()
	player_save.load_progress()
	assert_eq(player_save.get_level_source(player_save.DEFAULT_LEVEL), "test")

func test_highscore_save():
	player_save.load_progress()
	player_save.set_level_high_score(player_save.DEFAULT_LEVEL, 10)
	player_save = null
	player_save = PlayerSave.new()
	player_save.load_progress()
	assert_eq(player_save.get_level_high_score(player_save.DEFAULT_LEVEL), 10)

func after_each():
	player_save = null

func after_all():
	var dir = DirAccess.open(TEST_SAVE_DIR)
	if dir == null:
		fail_test("Unable to open user://save")
		return
	if dir.file_exists(TEST_SAVE_FILE):
		var result = dir.remove(TEST_SAVE_FILE)
		assert_eq(result, OK, "Unable to remove test save file")
