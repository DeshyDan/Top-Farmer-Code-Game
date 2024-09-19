class_name HelpItem
extends Resource
# Class contains help categories used in the help window

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

