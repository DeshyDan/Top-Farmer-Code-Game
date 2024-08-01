class_name Token

extends RefCounted

enum Type {
	VAR,
	WHILE,
	VAR_DECL,
	IDENT,
	FUNC,
	DOT,
	INTEGER,
	FLOAT,
	INTEGER_CONST,
	REAL_CONST,
	MUL,
	DIV,
	ASSIGN,
	PLUS,
	MINUS,
	LESS_THAN,
	GREATER_THAN,
	LPAREN,
	RPAREN,
	COLON,
	COMMA,
	BEGIN,
	END,
	HASH,
	NL,
	EOF
}

const TYPE_STRINGS =  {
	Type.VAR : "VAR",
	Type.WHILE : "WHILE",
	Type.VAR_DECL : "VAR_DECL",
	Type.IDENT : "IDENT",
	Type.FUNC : "FUNC",
	Type.DOT : "DOT",
	Type.INTEGER : "INTEGER",
	Type.FLOAT : "FLOAT",
	Type.INTEGER_CONST : "INTEGER",
	Type.REAL_CONST: "REAL_CONST",
	Type.MUL : "MUL",
	Type.DIV : "DIV",
	Type.ASSIGN : "ASSIGN",
	Type.PLUS : "PLUS",
	Type.MINUS : "MINUS",
	Type.LESS_THAN : "LESS_THAN",
	Type.GREATER_THAN : "GREATER_THAN",
	Type.LPAREN : "LPAREN",
	Type.RPAREN : "RPAREN",
	Type.COLON : "COLON",
	Type.COMMA : "COMMA",
	Type.BEGIN : "BEGIN",
	Type.END : "END",
	Type.HASH : "HASH",
	Type.NL : "NL",
	Type.EOF : "EOF"
}

var type
var value
var lineno
var colno
var length

func _init(type: Token.Type, value: Variant, lineno=null, colno=null, length=1):
	self.type = type
	self.value = value
	self.lineno = lineno
	self.colno = colno
	self.length = length

func _to_string() -> String:
	return "Token ({0},{1})".format([TYPE_STRINGS[type], value])
	
