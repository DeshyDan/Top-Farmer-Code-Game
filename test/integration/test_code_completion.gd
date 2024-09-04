extends GutTest

var code_window_scene = preload("res://scenes/code_window/window_ui.tscn")
var code_window: CodeWindow

var interpreter_client = InterpreterClient.new()

const CODE_EDIT_WAIT_TIME = 0.05

func before_all():
	code_window = code_window_scene.instantiate() as CodeWindow
	assert_not_null(code_window, "Unable to instantiate code window scene")
	add_child(code_window)
	if not code_window.is_node_ready():
		await code_window.ready
	assert_not_null(interpreter_client, "Unable to instantiate interpreter client scene")
	add_child(interpreter_client)
	if not interpreter_client.is_node_ready():
		await interpreter_client.ready

func before_each():
	code_window.code_edit.clear()
	code_window.code_edit.clear_undo_history()
	code_window.code_edit.grab_focus()

func test_keyword_completion():
	var key_words = Lexer.new("").keywords.keys().duplicate(true)
	await check_completion(key_words)
		
func test_func_completion():
	await check_completion(interpreter_client.DEFAULT_BUILTIN_FUNCS.keys(), true)

func test_const_completion():
	await check_completion(Const.DEFAULT_BUILTIN_CONSTS.keys())

func check_completion(keywords, is_function=false):
	var code_edit = code_window.code_edit
	
	for keyword in keywords:
		code_edit.grab_focus()
		#TODO: fix
		if keyword == "int":
			continue
		code_edit.start_action(TextEdit.ACTION_TYPING)
		code_edit.insert_text_at_caret(keyword[0])
		await wait_seconds(CODE_EDIT_WAIT_TIME)
		
		var options_has_keyword = false
		var option_index = 0
		var completion_text: String
		
		if is_function:
			completion_text = keyword + "()"
		else:
			completion_text = keyword
			
		for i in len(code_edit.get_code_completion_options()):
			if code_edit.get_code_completion_option(i)["display_text"] == completion_text:
				options_has_keyword = true
				option_index = i
		
		assert_true(options_has_keyword, 
					"Keyword {0} not found in code completion after {1} entered".format([
						keyword,
						keyword[0]
					]))
		
		code_edit.set_code_completion_selected_index(option_index)
		await wait_seconds(CODE_EDIT_WAIT_TIME)
		
		code_edit.confirm_code_completion()
		assert_eq(code_edit.text, completion_text, "Keyword replacement not working")
		code_edit.clear()



func after_all():
	code_window.queue_free()
	interpreter_client.queue_free()
