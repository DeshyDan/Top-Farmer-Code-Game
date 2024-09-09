class_name PlayerEdit
extends CodeEdit

@export var keyword_data_path: = "res://keywords.json"

@export var executing_color: Color
@export var comment_color: Color
@export var executing_highlight_length: float = 1

var _background_color: Color
var _tweening_lines = []
var _error_line = -1

# Called when the node enters the scene tree for the first time.
func _init():
	var keyword_data = FileAccess.get_file_as_string(keyword_data_path)
	var keywords = JSON.parse_string(keyword_data)
	for keyword in keywords["list"]:
		syntax_highlighter.keyword_colors[keyword] = Color.LIGHT_CORAL
		add_code_completion_option(CodeEdit.KIND_MEMBER, keyword,keyword)

func _ready():
	_background_color = get_theme_color("background_color")
	for key in Const.DEFAULT_BUILTIN_CONSTS:
		syntax_highlighter.keyword_colors[key] = Color.AQUAMARINE
	
	if not syntax_highlighter.has_color_region("#"):
		syntax_highlighter.add_color_region("#","", comment_color)
	
	# have to do this otherwise random godot functions show up
	update_code_completion_options(true)
	MessageBus.code_completion_set.connect(_on_code_completion_set)

func highlight_line(lineno):
	var tween = create_tween()
	tween.tween_method(
		func (color):
			if lineno == _error_line:
				return
			set_line_background_color(lineno-1,color), 
		executing_color, 
		_background_color, 
		executing_highlight_length
		).set_ease(Tween.EASE_IN)

func draw_error(lineno, colno, raw_message):
	set_line_background_color(lineno - 1, Color.RED * 0.4)
	_error_line = lineno

func _on_text_changed():
	request_code_completion()
	_error_line = -1
	for line in get_line_count():
		set_line_background_color(line, _background_color)

func _on_code_completion_requested():
	MessageBus.request_code_completion(text)

func _on_code_completion_set(options: Array[CodeCompletionOption]):
	for option in options:
		add_code_completion_option(
			option.kind,
			option.display,
			option.replacement, 
			Color.WHITE, null, 0)
	update_code_completion_options(false)
