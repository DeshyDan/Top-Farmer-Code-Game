class_name ActivationRecord
extends RefCounted

enum ARType {
	PROGRAM,
	FUNCTION_CALL
}

var name
var type: ARType
var nesting_level
var enclosing_ar: ActivationRecord
var members = {}
var return_val
var token: Token

func _init(name, type, nesting_level, enclosing_ar: ActivationRecord, token: Token, return_val=null):
	self.name = name
	self.type = type
	self.nesting_level = nesting_level
	self.enclosing_ar = enclosing_ar
	self.return_val = return_val
	self.token = token

func set_return(val):
	return_val = val

func set_item(key, value):
	members[key] = value

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
