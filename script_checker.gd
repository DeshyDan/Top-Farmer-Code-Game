class_name ErrorChecker
extends RefCounted

var error_text = []

func get_error_text() -> String:
	return error_text

func check_for_errors(source) -> Error:
	var engine_path = OS.get_executable_path()
	var output = []
	var file = FileAccess.open("player_code.gd", FileAccess.WRITE)
	file.store_string(source)
	file.close()
	var exit_code = OS.execute(engine_path, ["-s", "player_code.gd", "--check-only", "--headless"], output, true, false)
	print(output)
	print(exit_code)
	var out: String = output[0]
	error_text = out.split("\n",true,1)
	var dir = DirAccess.remove_absolute("res://player_code.gd")
	return exit_code
