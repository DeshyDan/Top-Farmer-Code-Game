extends GutTest

var params_features
var params_errors

const test_features_path = "res://test/test_scripts/lexer/features/"
const test_errors_path = "res://test/test_scripts/lexer/errors/"

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
			var expect = split[1].split("\n", false)
			param_values.append([file,source,expect])
		var params = ParameterFactory.named_parameters(param_names,param_values)
		if path == test_features_path:
			params_features = params
		else:
			params_errors = params

func test_lexer_errors(params=use_parameters(params_errors)):
	var lexer = Lexer.new(params.source)
	var token: Token = lexer.get_next_token()
	var expected_index = 0
	for expected: String in params.expected:
		if expected.begins_with("Error"):
			assert_ne(lexer.lexer_error, Lexer.LexerError.OK, params.filename)
			assert_eq(token.type, Token.Type.EOF)	# if we errored, should be EOF
			assert_eq(lexer.get_next_token().type, Token.Type.EOF) # every succussive call should be EOF
			break
		else:
			assert_eq(str(token), expected, get_token_source(token, params.source) + "{{0}}".format([expected_index]))
		token = lexer.get_next_token()
		expected_index += 1

func test_lexer_features(params=use_parameters(params_features)):
	var lexer = Lexer.new(params.source)
	var token = lexer.get_next_token()
	var expected_index = 0
	for expected in params.expected:
		assert_eq(str(token), expected, get_token_source(token, params.source) + "{{0}}".format([expected_index]))
		token = lexer.get_next_token()
		expected_index += 1
	assert_eq(token.type, Token.Type.EOF, params.filename + ": Extra tokens leftover")

func get_token_source(token: Token, source: String):
	var splitsource = source.split("\n")
	if token.lineno >= len(splitsource):
		return "Invalid token lineno, couldn't get source"
	var line: String = splitsource[token.lineno]
	return line.c_escape() + "[{0}]".format([token.lineno])
