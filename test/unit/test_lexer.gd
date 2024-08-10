extends GutTest

var params

const test_scripts_path = "res://test/test_scripts/lexer/"

func before_all():
	var diraccess = DirAccess.open(test_scripts_path)
	if not diraccess:
		return
	var files = diraccess.get_files()
	var param_names = ["source", "expected"]
	var param_values = []
	for file_index in files.size():
		var file = files[file_index]
		if not file.ends_with(".txt"):
			continue
		var source_string = FileAccess.get_file_as_string(test_scripts_path + file)
		if source_string == "":
			continue
		var split = source_string.split("#expect\n", true, 1)
		assert_eq(len(split),2, "Expected once #expect delimiter")
		var source = split[0]
		var expect = split[1].split("\n", false)
		param_values.append([source,expect])
	params = ParameterFactory.named_parameters(param_names,param_values)

func after_all():
	pass

func test_lexer(params=use_parameters(params)):
	var lexer = Lexer.new(params.source)
	var token = lexer.get_next_token()
	var expected_index = 0
	for expected in params.expected:
		assert_eq(str(token), expected, get_token_source(token, params.source) + "{{0}}".format([expected_index]))
		token = lexer.get_next_token()
		expected_index += 1

func get_token_source(token: Token, source: String):
	var splitsource = source.split("\n")
	if token.lineno >= len(splitsource):
		return "Invalid token lineno, couldn't get source"
	var line: String = splitsource[token.lineno]
	return line.c_escape() + "[{0}]".format([token.lineno])
