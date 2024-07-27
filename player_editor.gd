class_name PlayerEdit
extends CodeEdit

@export var keyword_data_path: = "res://keywords.json"
@export var class_color: = Color(0.6, 0.6, 1.0)
@export var member_color: = Color(0.6, 1.0, 0.6)
@export var keyword_color: = Color(1.0, 0.6, 0.6)
@export var quotes_color: = Color(1.0, 1.0, 0.6)

# Called when the node enters the scene tree for the first time.
func _init():
	var keyword_data = FileAccess.get_file_as_string(keyword_data_path)
	var keywords = JSON.parse_string(keyword_data)
	add_comment_delimiter("#","")
	for keyword in keywords["list"]:
		syntax_highlighter.keyword_colors[keyword] = Color.LIGHT_CORAL
		add_code_completion_option(CodeEdit.KIND_MEMBER, keyword,keyword)
		


	
