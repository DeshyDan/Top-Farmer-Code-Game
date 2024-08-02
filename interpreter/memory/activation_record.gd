class_name ActivationRecord
extends RefCounted

enum ARType {
	PROGRAM,
	FUNCTION_CALL
}

var name
var type: ARType
var nesting_level
var members = {}
var return_val

func _init(name, type, nesting_level, return_val=null):
	self.name = name
	self.type = type
	self.nesting_level = nesting_level
	self.return_val = return_val

func set_return(val):
	return_val = val

func set_item(key, value):
	members[key] = value

func get_item(key):
	return members.get(key)

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
