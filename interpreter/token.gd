class_name Token

extends RefCounted

enum Type {
	VAR,
	VAR_DECL,
	IDENT,
	FUNC,
	DOT,
	INTEGER,
	MUL,
	DIV,
	ASSIGN,
	PLUS,
	MINUS,
	LPAREN,
	RPAREN,
	BEGIN,
	END,
	NL,
	EOF
}

const TYPE_STRINGS =  {
	Type.VAR : "VAR",
	Type.VAR_DECL : "VAR_DECL",
	Type.IDENT : "IDENT",
	Type.FUNC : "FUNC",
	Type.DOT : "DOT",
	Type.INTEGER : "INTEGER",
	Type.MUL : "MUL",
	Type.DIV : "DIV",
	Type.ASSIGN : "ASSIGN",
	Type.PLUS : "PLUS",
	Type.MINUS : "MINUS",
	Type.LPAREN : "LPAREN",
	Type.RPAREN : "RPAREN",
	Type.BEGIN : "BEGIN",
	Type.END : "END",
	Type.NL : "NL",
	Type.EOF : "EOF"
}

var type
var value

func _init(type: Type, value: Variant):
	self.type = type
	self.value = value

func _to_string() -> String:
	return "Token ({0},{1})".format([TYPE_STRINGS[type], value])
	
