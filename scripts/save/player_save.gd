class_name PlayerSave
extends Resource

const DEFAULT_LEVEL = 1.0

static var save_path = "user://code_game/save_file.save"

var _source_codes = {}
var _level_high_scores = {}
var _unlocked_levels = []

func set_level_high_score(level, score):
	_level_high_scores[str(level)] = score
	save_progress()

func get_level_high_score(level):
	return _level_high_scores.get(str(level))

func get_level_source(level) -> String:
	var lvl_str = str(level)

	if _source_codes.has(lvl_str):
		return _source_codes[lvl_str]

	_source_codes[lvl_str] = ""
	return ""

func update_level_source(level, source: String):
	var lvl_str = str(level)
	_source_codes[lvl_str] = source
	save_progress()

func unlock_level(level):
	if level in _unlocked_levels:
		push_warning("level already unlocked for this save")
		return

	_unlocked_levels.append(level)
	save_progress()

func save_progress():
	if not is_instance_valid(self):
		push_error("tried to save an invalid player save")
		return

	var file = FileAccess.open(save_path,FileAccess.WRITE)
	if not file:
		return
	
	file.store_line(JSON.stringify(_unlocked_levels))
	file.store_line(JSON.stringify(_source_codes))
	file.store_line(JSON.stringify(_level_high_scores))
	file.close()

func load_progress():
	if not FileAccess.file_exists(save_path):
		var dir = DirAccess.open("user://")
		dir.make_dir("code_game")
		unlock_level(DEFAULT_LEVEL)
		save_progress()

	var file = FileAccess.open(save_path, FileAccess.READ)

	_unlocked_levels = JSON.parse_string(file.get_line())
	if _unlocked_levels == null:
		_unlocked_levels = []
		unlock_level(DEFAULT_LEVEL)
		push_error("Corrupted unlocked levels, restoring to defaults")

	_source_codes = JSON.parse_string(file.get_line())
	if _source_codes == null:
		_source_codes = {}
		update_level_source(DEFAULT_LEVEL, "")
		push_error("Corrupted player source code, restoring to defaults")

	var json_line = file.get_line()
	_level_high_scores = JSON.parse_string(json_line)
	if _level_high_scores == null:
		_level_high_scores = {}
		for lvl in _unlocked_levels:
			_level_high_scores[str(lvl)] = 0
		push_error("Corrupted high scores, restoring to defaults")
	
	print("Loaded save:")
	print(_unlocked_levels)
	print(_level_high_scores)
	print(_source_codes)
