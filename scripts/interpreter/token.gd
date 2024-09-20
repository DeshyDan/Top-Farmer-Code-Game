class_name Token
extends RefCounted

# Token class representing a single 
# keyword, operator or identifier.

var type
var value
var lineno
var colno
var length

enum Type {
	VAR,
	#PRINT,
	IF,
	ELSE,
	LOGIC_NOT,
	LOGIC_OR,
	LOGIC_AND,
	IN,
	FOR,
	WHILE,
	RETURN,
	BREAK,
	CONTINUE,
	VAR_DECL,
	IDENT,
	FUNC,
	DOT,
	TRUE,
	FALSE,
	PI_CONST,
	NULL,
	INTEGER,
	FLOAT,
	INTEGER_CONST,
	REAL_CONST,
	MUL,
	DIV,
	MOD,
	BANG,
	ASSIGN,
	PLUS,
	MINUS,
	IS_EQUAL,
	IS_NOT_EQUAL,
	LESS_THAN,
	LT_OR_EQ,
	GREATER_THAN,
	GT_OR_EQ,
	LPAREN,
	RPAREN,
	LSQUARE,
	RSQUARE,
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
	#"Type.#PRINT : #PRINT",
	Type.IF : "IF",
	Type.ELSE : "ELSE",
	Type.LOGIC_NOT : "LOGIC_NOT",
	Type.LOGIC_OR : "LOGIC_OR",
	Type.LOGIC_AND : "LOGIC_AND",
	Type.IN : "IN",
	Type.FOR : "FOR",
	Type.WHILE : "WHILE",
	Type.RETURN : "RETURN",
	Type.BREAK : "BREAK",
	Type.CONTINUE : "CONTINUE",
	Type.VAR_DECL : "VAR_DECL",
	Type.IDENT : "IDENT",
	Type.FUNC : "FUNC",
	Type.DOT : "DOT",
	Type.TRUE : "TRUE",
	Type.FALSE : "FALSE",
	Type.PI_CONST : "PI_CONST",
	Type.NULL : "NULL",
	Type.INTEGER : "INTEGER",
	Type.FLOAT : "FLOAT",
	Type.INTEGER_CONST : "INTEGER_CONST",
	Type.REAL_CONST : "REAL_CONST",
	Type.MUL : "MUL",
	Type.DIV : "DIV",
	Type.MOD : "MOD",
	Type.BANG : "BANG",
	Type.ASSIGN : "ASSIGN",
	Type.PLUS : "PLUS",
	Type.MINUS : "MINUS",
	Type.IS_EQUAL : "IS_EQUAL",
	Type.IS_NOT_EQUAL : "IS_NOT_EQUAL",
	Type.LESS_THAN : "LESS_THAN",
	Type.LT_OR_EQ : "LT_OR_EQ",
	Type.GREATER_THAN : "GREATER_THAN",
	Type.GT_OR_EQ : "GT_OR_EQ",
	Type.LPAREN : "LPAREN",
	Type.RPAREN : "RPAREN",
	Type.LSQUARE : "LSQUARE",
	Type.RSQUARE : "RSQUARE",
	Type.COLON : "COLON",
	Type.COMMA : "COMMA",
	Type.BEGIN : "BEGIN",
	Type.END : "END",
	Type.HASH : "HASH",
	Type.NL : "NL",
	Type.EOF : "EOF"
}


func _init(type: Token.Type, value: Variant, lineno=null, colno=null, length=1):
	self.type = type
	self.value = value
	self.lineno = lineno
	self.colno = colno
	self.length = length

func _to_string() -> String:
	return "Token ({0},{1})".format([TYPE_STRINGS[type], value])
	
