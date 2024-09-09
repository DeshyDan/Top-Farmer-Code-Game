class_name ActivationRecord
extends RefCounted

enum ARType {
	PROGRAM,
	FUNCTION_CALL,
	FOR_LOOP
}

var name
var type: ARType
var nesting_level
var enclosing_ar: ActivationRecord
var members = {}
var return_val
var token: Token
var should_return = false
var should_break = false
var should_continue = false
var error: RuntimeError

func _init(name, type, nesting_level, enclosing_ar: ActivationRecord, token: Token):
	self.name = name
	self.type = type
	self.nesting_level = nesting_level
	self.enclosing_ar = enclosing_ar
	self.return_val = null
	self.token = token
	error = RuntimeError.new(RuntimeError.ErrorCode.OK)

func set_error(runtime_error: RuntimeError):
	error = runtime_error
	# recursively set error until top of stack
	if enclosing_ar:
		enclosing_ar.set_error(runtime_error)

func set_return(val):
	should_return = true
	return_val = val

func set_break():
	should_break = true
	if enclosing_ar != null:
		enclosing_ar.set_break()

func set_continue():
	should_continue = true
	if enclosing_ar != null:
		enclosing_ar.set_continue()

func reset_break():
	should_break = false
	if enclosing_ar != null:
		enclosing_ar.reset_break()

func reset_continue():
	should_continue = false
	if enclosing_ar != null:
		enclosing_ar.set_continue()

func set_item(key, value, _members=members):
	if members.has(key):
		members[key] = value
	else:
		if enclosing_ar == null:
			_members[key] = value	# original ar members
			return
		enclosing_ar.set_item(key,value,_members)
	

func get_item(key):
	var result = members.get(key)
	if result == null:
		if enclosing_ar == null:
			return null
		return enclosing_ar.get_item(key)
	return result

func _to_string():
	var lines = [
			'{level}: {type} {name}'.format({
				level=nesting_level,
				type=type,
				name=name,
			})
		]
	for key in members:
		lines.append('   {name}: {val}'.format({
			"name": key,
			"val": members[key]
		}))

	var s = '\n'.join(lines)
	return s
