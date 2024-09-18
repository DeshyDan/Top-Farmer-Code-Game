extends Main

var fps_data = []
var frame_time_data = []

func _process(delta):
	fps_data.push_back(Performance.get_monitor(Performance.TIME_FPS))
	frame_time_data.push_back(Performance.get_monitor(Performance.TIME_PROCESS))

func _exit_tree():
	var file_access = FileAccess.open("res://test/perf_data.csv", FileAccess.WRITE)
	if not file_access:
		push_error("unable to store perf test data")
		return
	for i in min(len(frame_time_data), len(fps_data)):
		file_access.store_csv_line([i,fps_data[i], frame_time_data[i]])
