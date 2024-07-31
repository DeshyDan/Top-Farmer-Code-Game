class_name Token

extends RefCounted

enum Type {
	VAR,
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

func _init(type: Token.Type, value: Variant):
	self.type = type
	self.value = value

func _to_string() -> String:
	return "Token ({0},{1})".format([TYPE_STRINGS[type], value])
	
