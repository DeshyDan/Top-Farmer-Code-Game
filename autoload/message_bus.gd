# MessageBus
extends Node

signal code_completion_requested(source: String)
signal code_completion_set(options: Array[CodeCompletionOption])
signal hint_clicked(metadata)

func request_code_completion(source: String):
	code_completion_requested.emit(source)

func set_code_completion_options(options: Array[CodeCompletionOption]):
	code_completion_set.emit(options)

func request_hint_click(metadata):
	hint_clicked.emit(metadata)
