class_name GError
extends RefCounted

# Base error class from which all Error
# types inherit from. Has to be named GError
# since Error is already taken by an engine 
# enum.

enum ErrorCode {
	OK = 0,
	# lexer errors
	INVALID_CHAR,
	
	# parser errors
	UNEXPECTED_TOKEN,
	
	# semantic errors
	ID_NOT_FOUND,
	DUPLICATE_ID,
	
	# runtime errors
	DIV_BY_ZERO,
	RECURSION_ERR,
	REF_ERROR,
}

var error_code: ErrorCode
var token: Token
var message: String
var raw_message: String

func _init(error_code: ErrorCode, 
			token: Token = null,
			message: String = "Unknown Error"):
	self.error_code = error_code
	self.token = token
	raw_message = message
	# add exception class name before the message
	if token:
		self.message = "{0}: [{1}:{2}]: {3}".format([str(self),token.lineno,token.colno,message])
	else:
		self.message = "{0}: {2}".format([str(self),message])

func _to_string():
	return "Error"
