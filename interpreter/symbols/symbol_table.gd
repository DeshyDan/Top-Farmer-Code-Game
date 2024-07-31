class_name SymbolTable
extends RefCounted

var _symbols = {}

func _init():
	_init_builtins()

func _to_string():
	return "Symbols: {0}".format([_symbols])

func define(symbol: Symbol):
	print("define {0}".format([symbol]))
	_symbols[symbol.name] = symbol

func lookup(name):
	print("lookup {0}".format([name]))
	return _symbols.get(name)

func _init_builtins():
	define(BuiltinSymbol.new("int"))
	define(BuiltinSymbol.new("float"))
