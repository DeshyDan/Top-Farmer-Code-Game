class_name CodeCompletionOption
extends RefCounted
# Class handles logic for code completion

var kind: CodeEdit.CodeCompletionKind
var display: String
var replacement: String
var location: CodeEdit.CodeCompletionLocation

const KIND_VAR = CodeEdit.CodeCompletionKind.KIND_MEMBER
const KIND_KEYWORD = CodeEdit.CodeCompletionKind.KIND_SIGNAL
const KIND_FUNC = CodeEdit.CodeCompletionKind.KIND_FUNCTION
const KIND_CONST = CodeEdit.CodeCompletionKind.KIND_CONSTANT

const LOC_PLAYER = CodeEdit.CodeCompletionLocation.LOCATION_LOCAL
const LOC_BUILTIN = CodeEdit.CodeCompletionLocation.LOCATION_OTHER_USER_CODE

func _init(_replacement: String, _kind: int, _location: int):
	replacement = _replacement
	kind = _kind as CodeEdit.CodeCompletionKind
	display = replacement
	if kind == KIND_FUNC:
		replacement += "("
		display = replacement + ")"
	location = _location as CodeEdit.CodeCompletionLocation

static func func_option(name: String, builtin = false) -> CodeCompletionOption:
	var loc = LOC_BUILTIN if builtin else LOC_PLAYER
	return CodeCompletionOption.new(name, KIND_FUNC, loc)

static func var_option(name: String) -> CodeCompletionOption:
	return CodeCompletionOption.new(name,KIND_VAR,LOC_PLAYER)

static func const_option(name: String, builtin = false) -> CodeCompletionOption:
	var loc = LOC_BUILTIN if builtin else LOC_PLAYER
	return CodeCompletionOption.new(name, KIND_CONST, loc)

static func keyword_option(name: String) -> CodeCompletionOption:
	return CodeCompletionOption.new(name, KIND_KEYWORD, LOC_BUILTIN)
