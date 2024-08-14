class_name Level

extends Node2D
@onready var window: CodeWindow = $Window
@onready var farm: FarmView = $Farm
@onready var interpreter_client: InterpreterClient = $InterpreterClient

var timer: Timer

@export var tick_rate = 4

# TODO: make it so that an arbitrary farm goal and farm start state
# can be set

func set_level(width, height):
	farm.height = height
	farm.width = width 

# TODO: test that this scene can be instantiated from anywhere without
# breaking

# TODO: tick the farm after/before we tick the player. keep them in sync!

# TODO: make it so that a tracepoint from the interpreter can wait n ticks
# before continuing

# TODO: keep track of the players score

func _on_window_run_button_pressed():
	# TODO: clear window.console
	if not interpreter_client.load_source(window.get_source_code()):
		return
	interpreter_client.start()
	# TODO: tick length zero => pause timer 
	var tick_length = 1.0/(float(tick_rate) + 0.00001)
	if timer and timer.is_inside_tree():
		remove_child(timer)
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_tick)
	timer.start(tick_length)

func _on_window_pause_button_pressed():
	if not timer:
		return
	timer.paused = not timer.paused

func _on_window_kill_button_pressed():
	if timer and timer.is_inside_tree():
		remove_child(timer)
	interpreter_client.kill()

func _on_timer_tick():
	# TODO: check for victory here
	interpreter_client.tick()

func _on_print_call(args: Array):
	window.print_to_console(" ".join(args))

func _on_move_call(args: Array):
	farm.move(args[0])

func _on_plant_call(args: Array):
	farm.plant(args[0])

func _on_harvest_call(args: Array):
	farm.harvest()

# the interpreter client has reached a line, we should highlight it
func _on_tracepoint_reached(node: AST, call_stack: CallStack):
	window.highlight_tracepoint(node, call_stack)

func _on_interpreter_client_finished():
	print("INTERPRETER FINISHED")
	if timer:
		remove_child(timer)
	# TODO: show failure screen here

func _on_interpreter_client_error(message):
	window.print_to_console(message)

func _exit_tree():
	Node.print_orphan_nodes()
