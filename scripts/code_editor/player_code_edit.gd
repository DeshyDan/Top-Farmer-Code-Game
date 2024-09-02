class_name PlayerEdit
extends CodeEdit

@export var keyword_data_path: = "res://keywords.json"

@export var executing_color: Color
@export var executing_highlight_length: float = 1
@export var comment_color: Color

var _background_color: Color
var _tweening_lines = []
# Called when the node enters the scene tree for the first time.
func _init():
	var keyword_data = FileAccess.get_file_as_string(keyword_data_path)
	var keywords = JSON.parse_string(keyword_data)
	for keyword in keywords["list"]:
		syntax_highlighter.keyword_colors[keyword] = Color.LIGHT_CORAL
		add_code_completion_option(CodeEdit.KIND_MEMBER, keyword, keyword)

func _ready():
	_background_color = get_theme_color("background_color")
	for key in Const.DEFAULT_BUILTIN_CONSTS:
		syntax_highlighter.keyword_colors[key] = Color.AQUAMARINE
	#syntax_highlighter.add_color_region("#","", comment_color)
	# have to do this otherwise random godot functions show up
	update_code_completion_options(true)

func highlight_line(lineno):
	var tween = create_tween()
	tween.tween_method(
		func (color):
			set_line_background_color(lineno,color), 
		executing_color, 
		_background_color, 
		executing_highlight_length
		).set_ease(Tween.EASE_IN)

func _process(delta):
	pass

func draw_error(lineno, colno, length):
	pass

func _on_text_changed():
	request_code_completion()

func _on_code_completion_requested():
	MessageBus.request_code_completion(text)
