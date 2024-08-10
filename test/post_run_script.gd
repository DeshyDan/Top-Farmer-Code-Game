extends GutHookScript

func run():
	# Note, this will node will be included in the stray node list.
	var n = Node.new()
	n.name = "OrphanPrinter"
	n.print_orphan_nodes()
	n.free()
