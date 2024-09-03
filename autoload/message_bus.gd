
extends Node

signal code_completion_requested(source: String)
signal code_completion_set(options: Array[CodeCompletionOption])
signal interpreter_input(data: Variant)

func send_input(data: Variant):
	_send_input.call_deferred(data)

func _send_input(data: Variant):
	interpreter_input.emit(data)

func request_code_completion(source: String):
	code_completion_requested.emit(source)

func set_code_completion_options(options: Array[CodeCompletionOption]):
	code_completion_set.emit(options)
