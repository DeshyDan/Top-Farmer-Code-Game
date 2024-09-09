extends GutTest

var params_features
var params_errors

const test_features_path = "res://test/test_scripts/interpreter/features/"
const test_errors_path = "res://test/test_scripts/interpreter/errors/"

var interpreter: Interpreter
var mut = Mutex.new()
var ticker_thread: Thread
var output: String = ""

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

func before_each():
	output = ""

func autotick(_n, _c):
	_autotick.call_deferred()

func _autotick():
	interpreter.tick.emit()

func save_output(func_name, args):
	if func_name == "print":
		_save_output.call_deferred(args)

func _save_output(args):
	var out = str(args[0])
	output += out + "\n"

func test_interpreter_features(params=use_parameters(params_features)):
	var lexer = Lexer.new(params.source)
	var parser = Parser.new(lexer)
	var tree = parser.parse()
	assert_eq(parser.parser_error.error_code, GError.ErrorCode.OK, "{0}: Unexpected parser error: {1}".format([params.filename, parser.parser_error.message]))
	var tree_str = str(tree)
	var expected_index = 0
	var expected_str = params.expected as String
	#print(tree_str)
	var expected_print = expected_str
	interpreter = Interpreter.new(tree)
	interpreter.tracepoint.connect(autotick)
	interpreter.builtin_func_call.connect(save_output)
	await interpreter.start()
	#await wait_for_signal(interpreter.finished, 5, "waiting for interpreter to finish")
	assert_eq_deep(output.c_escape(), expected_print.c_escape())

func test_interpreter_errors(params=use_parameters(params_errors)):
	var lexer = Lexer.new(params.source)
	var parser = Parser.new(lexer)
	var tree = parser.parse()
	assert_eq(parser.parser_error.error_code, GError.ErrorCode.OK, "{0}: Unexpected parser error: {1}".format([params.filename, parser.parser_error.message]))
	var tree_str = str(tree)
	var expected_index = 0
	var expected_str = params.expected as String
	#print(tree_str)
	var expected_print = expected_str
	interpreter = Interpreter.new(tree)
	interpreter.start()
	await wait_until(check_error, 15)
	var ar = interpreter.call_stack.peek()
	assert_ne(ar.error.error_code, RuntimeError.ErrorCode.OK, "Expected parser error")

func check_error():
	var ar = interpreter.call_stack.peek()
	var result = ar.error.error_code != RuntimeError.ErrorCode.OK
	interpreter.tick.emit()
	return result

func after_each():
	interpreter = null

func after_all():
	interpreter = null

func get_token_source(token: Token, source: String):
	var splitsource = source.split("\n")
	if token.lineno >= len(splitsource):
		return "Invalid token lineno, couldn't get source"
	var line: String = splitsource[token.lineno]
	return line.c_escape() + "[{0}]".format([token.lineno])
