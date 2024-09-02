class_name PlayerSave
extends Resource

static var save_path = "user://code_game/save_file.save"

var _source_codes = {}
var _level_high_scores = {}
var _unlocked_levels = []

func get_level_high_score(level):
	return _level_high_scores.get(level)

func get_level_source(level) -> String:
	level = str(level)
	if _source_codes.has(level):
		return _source_codes[level]
	_source_codes[level] = ""
	return ""

func update_level_code(level, source: String):
	level = str(level)
	_source_codes[level] = source
	save_progress()

func unlock_level(level):
	if level in _unlocked_levels:
		push_error("level already unlocked for this save")
		return
	_unlocked_levels.append(level)
	save_progress()

func save_progress():
	if not is_instance_valid(self):
		push_error("tried to save an invalid player save")
		return
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	file.store_line(JSON.stringify(_unlocked_levels))
	file.store_line(JSON.stringify(_source_codes))
	file.store_line(JSON.stringify(_level_high_scores))
	file.close()

func load_progress():
	if not FileAccess.file_exists(save_path):
		var dir = DirAccess.open("user://")
		dir.make_dir("code_game")
		_unlocked_levels.append(3)
		save_progress()
	var file = FileAccess.open(save_path, FileAccess.READ)
	_unlocked_levels = JSON.parse_string(file.get_line())
	_source_codes = JSON.parse_string(file.get_line())
	_level_high_scores = JSON.parse_string(file.get_line())
	print(_unlocked_levels)
