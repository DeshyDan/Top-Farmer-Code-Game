extends GutTest

var params

const test_scripts_path = "res://test/test_scripts/parser/"

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
		assert_eq(len(split),2, "Expected one #expect delimiter")
		var source = split[0]
		var expect = split[1]
		param_values.append([source,expect])
	params = ParameterFactory.named_parameters(param_names,param_values)

func test_parser(params=use_parameters(params)):
	var lexer = Lexer.new(params.source)
	var parser = Parser.new(lexer)
	var tree = parser.parse()
	var tree_str = str(tree)
	var expected_index = 0
	if assert_eq(len(tree_str), len(params.expected), "length mismatch"):
		var expected_len = len(params.expected)
		var actual_len = len(tree_str)
		fail_test("\n" + tree_str + params.expected)
		return
	for i in range(len(tree_str)):
		assert_eq(tree_str[i], 
				params.expected[i], 
				"mismatch at {0}: {1} != {2}".format(
				  [str(i),
					str(tree_str[i]),
					str(params.expected[i])
				]))# just test the str output of the tree is the same for now

func get_token_source(token: Token, source: String):
	var splitsource = source.split("\n")
	if token.lineno >= len(splitsource):
		return "Invalid token lineno, couldn't get source"
	var line: String = splitsource[token.lineno]
	return line.c_escape() + "[{0}]".format([token.lineno])
