class_name SymbolTableBuilder
extends NodeVisitor

# Visitor class that traverses the AST and keeps track of
# what variables have been declared, and which scope they
# belong to.

var symtab: SymbolTable

func _init():
	symtab = SymbolTable.new("global",1,null)

func symbol_table_err(from):
	print("Semantic error from {0}".format(from))

func visit_program(node):
	visit(node.block)

func visit_binary_op(node):
	visit(node.left)
	visit(node.right)

func visit_unary_op(node):
	visit(node.expr)

func visit_block(node):
	for child in node.children:
		visit(child)
		
func visit_assignment(node: Assignment):
	var var_name = node.left.name
	var var_symbol = symtab.lookup(var_name)
	if var_symbol == null:
		print("symbol table assignment failed")
	visit(node.right)

func visit_var(node: Var):
	var var_name = node.name
	var var_symbol = symtab.lookup(var_name)
	if var_symbol == null:
		symbol_table_err("symbol table lookup failed")

func visit_var_decl(node: VarDecl):
	var type_name = node.type_node.type_name
	var type_symbol = symtab.lookup(type_name)
	var var_name = node.var_node.name
	var var_symbol = VarSymbol.new(var_name, type_symbol)
	symtab.define(var_symbol)
