class_name NoOp
extends AST

func node_string(indent: int):
    var indent_str = " ".repeat(indent)
    return "%sNoOp\n" % indent_str