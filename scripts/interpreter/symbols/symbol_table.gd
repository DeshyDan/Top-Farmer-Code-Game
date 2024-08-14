class_name SymbolTable
extends RefCounted

var _symbols = {}
var scope_name: String
var scope_level: int
var enclosing_scope: SymbolTable

func _init(scope_name: String, scope_level: int, enclosing_scope: SymbolTable):
	_symbols = {}
	self.scope_name = scope_name
	self.scope_level = scope_level
	self.enclosing_scope = enclosing_scope
	_init_builtins()

func _to_string():
	return "Symbols: {0}".format([_symbols])

func define(symbol: Symbol):
	_symbols[symbol.name] = symbol

func lookup(name) -> Symbol:
	var symbol = _symbols.get(name)
	if symbol != null:
		return symbol
	if enclosing_scope == null:
		return symbol
	return enclosing_scope.lookup(name)

func _init_builtins():
	define(BuiltinSymbol.new("int"))
	define(BuiltinSymbol.new("float"))
	define(BuiltinSymbol.new("true"))
	define(BuiltinFuncSymbol.new("print", [0])) # TODO: what should this array actually contain?
	define(BuiltinFuncSymbol.new("move", [0]))
	define(BuiltinFuncSymbol.new("plant", [0]))
	define(BuiltinFuncSymbol.new("harvest", []))
	define(BuiltinSymbol.new("false"))
