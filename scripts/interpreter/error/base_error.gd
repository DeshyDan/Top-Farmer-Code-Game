class_name GError
extends RefCounted

enum ErrorCode {
	OK,
	UNEXPECTED_TOKEN,
	ID_NOT_FOUND,
	DUPLICATE_ID
}

var error_code: ErrorCode
var token: Token
var message: String

func _init(error_code: ErrorCode, 
			token: Token = null,
			message: String = "Unknown Error"):
	self.error_code = error_code
	self.token = token
	# add exception class name before the message
	if token:
		self.message = "{0} [{1}:{2}]: {3}".format([str(self),token.lineno,token.colno,message])
	else:
		self.message = "{0}: {2}".format([str(self),message])

func _to_string():
	return "Error"
