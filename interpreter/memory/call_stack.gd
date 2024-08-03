class_name CallStack
extends RefCounted

var _items: Array[ActivationRecord]

func push(x: ActivationRecord):
	_items.push_back(x)

func pop() -> ActivationRecord:
	return _items.pop_back()

func peek() -> ActivationRecord:
	return _items[-1]

func _to_string():
	var rev = _items.duplicate()
	rev.reverse()
	var s = "Call Stack:\n"
	s += "\n".join(rev)
	return s + "\n"

func shallow_copy() -> CallStack:
	var new_callstack = CallStack.new()
	for item in _items:
		new_callstack.push(item)
	return new_callstack
