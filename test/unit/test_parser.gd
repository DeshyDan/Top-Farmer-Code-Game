extends GutTest

var params_features
var params_errors

const test_features_path = "res://test/test_scripts/parser/features/"
const test_errors_path = "res://test/test_scripts/parser/errors/"

func before_all():
	for path in [test_errors_path,test_features_path]:
		var diraccess = DirAccess.open(path)
		if not diraccess:
			return
		var files = diraccess.get_files()
		var param_names = ["filename","source", "expected"]
		var param_values = []
		for file_index in files.size():
			var file = files[file_index]
			if not file.ends_with(".txt"):
				continue
			var source_string = FileAccess.get_file_as_string(path + file)
			if source_string == "":
				continue
			var split = source_string.split("#expect\n", true, 1)
			assert_eq(len(split),2, "Expected once #expect delimiter")
			var source = split[0]
			var expect = split[1]
			param_values.append([file,source,expect])
		var params = ParameterFactory.named_parameters(param_names,param_values)
		if path == test_features_path:
			params_features = params
		else:
			params_errors = params

func test_parser_features(params=use_parameters(params_features)):
	var lexer = Lexer.new(params.source)
	var parser = Parser.new(lexer)
	var tree = parser.parse()
	assert_eq(parser.parser_error.error_code, GError.ErrorCode.OK, "{0}: Unexpected parser error: {1}".format([params.filename, parser.parser_error.message]))
	var tree_str = str(tree)
	var expected_index = 0
	if assert_eq(len(tree_str), len(params.expected), "length mismatch"):
		var expected_len = len(params.expected)
		var actual_len = len(tree_str)
		fail_test("\n" + tree_str + params.expected)
		return
	var expected_str = params.expected as String
	if expected_str.contains("\t"):
		fail_test("Make sure the %s file is switched from tabs to spaces for testing" % params.filename)
		return
	for i in range(len(tree_str)):
		assert_eq(tree_str[i], 
				params.expected[i], 
				"mismatch at {0}: {1} != {2}".format(
				  [str(i),
					str(tree_str[i]),
					str(params.expected[i])
				]))# just test the str output of the tree is the same for now

func test_parser_errors(params=use_parameters(params_errors)):
	var lexer = Lexer.new(params.source)
	var parser = Parser.new(lexer)
	var tree = parser.parse()
	assert_ne(parser.parser_error.error_code, GError.ErrorCode.OK, "%s: Expected parser error" % params.filename)

func get_token_source(token: Token, source: String):
	var splitsource = source.split("\n")
	if token.lineno >= len(splitsource):
		return "Invalid token lineno, couldn't get source"
	var line: String = splitsource[token.lineno]
	return line.c_escape() + "[{0}]".format([token.lineno])
