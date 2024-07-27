extends Button
@onready var panel_container = $"../PanelContainer"

func _pressed():
	var engine_path = OS.get_executable_path()
	var output = []
	var source = panel_container.get_source()
	var file = FileAccess.open("player_code.gd", FileAccess.WRITE)
	file.store_string(source)
	file.close()
	var exit_code = OS.execute(engine_path, ["-s", "player_code.gd", "--check-only", "--headless"], output, true, false)
	print(output)
	print(exit_code)
