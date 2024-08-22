class_name HelpItem

extends Resource

@export_enum(
	"Basic syntax",
	"Functions",
	"Loops",
	"Builtin constants",
	"Operators",
	"Control flow",
	"Tips and tricks"
) var category: String

@export var title: String
@export_multiline var content: String

#func _init(_title: String, _content: String, _category: String):
	#title = _title
	#content = _content
	#category = _category
#
