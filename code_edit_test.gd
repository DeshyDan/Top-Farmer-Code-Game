extends Window

@export var code_edit: CodeEdit
@export var console: RichTextLabel

var robot: Robot

@onready var expression = Expression.new()

func _on_button_pressed():
	console.text = ""
	if is_instance_valid(robot):
		robot.queue_free()
	var source = code_edit.text
	
	var error_checker = ErrorChecker.new()
	if error_checker.check_for_errors(source) != 0:
		MessageBus.print_requested.emit(error_checker.error_text, null, null, null)
		return
	
	source = replace_print_calls_in_script(code_edit.name,source)
	
	for line in source.split("\n"):
		if line == "":
			continue
		var parse_error = expression.parse(line)
		if parse_error != 0 and parse_error != 31:
			MessageBus.print_requested.emit([expression.get_error_text(), parse_error], null, null, null)
			return
	
	var script = GDScript.new()
	script.source_code = source
	var error = script.reload(true)
	if error != Error.OK:
		print("oopsies! => " + str(error))
		return
	
	
	
	robot = script.new() as Robot
	robot.__reset__()
	get_parent().add_child(robot)



var script_replacements := RegExpGroup.collection(
	{
		"\\b(?<command>prints)\\((?<args>.*?)\\)":
		"MessageBus.print_log([{args}], \"{file}\", {line}, {char})",
		"\\b(?<command>print)\\((?<args>.*?)\\)":
		"MessageBus.print_log([{args}], \"{file}\", {line}, {char})",
		"\\b(?<command>push_error)\\((?<args>.*?)\\)":
		"MessageBus.print_error({args}, \"{file}\", {line}, {char})",
		"\\b(?<command>push_warning)\\((?<args>.*?)\\)":
		"MessageBus.print_warning({args}, \"{file}\", {line}, {char})",
		"\\b(?<command>assert)\\((?<args>.*?)\\)":
		"MessageBus.print_assert({args}, \"{file}\", {line}, {char})",
	}
)

func replace_print_calls_in_script(script_file_name: String, script_text: String) -> String:
	var lines = script_text.split("\n")
	for line_nb in lines.size():
		var line: String = lines[line_nb]
		for _regex in script_replacements._regexes:
			var regex: RegEx = _regex as RegEx
			var replacement: String = script_replacements._regexes[regex]
			var start := 0
			var end := line.length()
			while start < end:
				var maybe_match = regex.search(line, start)
				if not maybe_match:
					start = end
					break
				else:
					var m := maybe_match as RegExMatch
					var starting_char := m.get_start()
					var ending_char := m.get_end()
					var args = m.get_string("args")
					#if args and args[0] == '"':
						## Godot somehow removes `"` if they are the first
						## character of a string
						#args = " " + args
					var command = m.get_string("command")
					var config = {
						"command": command,
						"args": args,
						"line": line_nb,
						"file": script_file_name,
						"char": starting_char,
					}
					var slice_middle := replacement.format(config)
					var slice_beginning := line.left(starting_char)
					var slice_end := line.right(ending_char)
					
					var replaced_line := slice_beginning + slice_middle #+ slice_end
					var diff := int(abs(replaced_line.length() - line.length()))
					start = ending_char + diff
					lines[line_nb] = replaced_line
	return "\n".join(lines)

	
	
	


func _on_pause_pressed():
	if is_instance_valid(robot):
		robot.set_process(!robot.is_processing())


func _on_kill_pressed():
	if is_instance_valid(robot):
		robot.free()
