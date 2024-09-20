class_name NoOp
extends AST

# AST node representing a no-op,
# does nothing

func node_string(indent: int):
    var indent_str = " ".repeat(indent)
    return "%sNoOp\n" % indent_str
