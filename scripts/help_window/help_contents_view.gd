class_name HelpContents
extends Tree
# Class Creates a tree data structure for storing and managing help items

var categories = {}
signal help_contents_item_selected(help_item: HelpItem)
var contents_root: TreeItem

# Connect signals from the Tree
func _ready():
	item_selected.connect(_on_tree_item_selected)

# This draws the tree from a data structure provided ("model")
func update_tree(model: Array[HelpItem]):
	clear()
	contents_root = create_item()
	# Set the text label for this item (the 0 specifies the Tree column)
	contents_root.set_text(0, "Contents") 
	for help_item in model:
		if help_item == null:
			push_error("null help window contents item")
		if not categories.get(help_item.category):
			var category_tree_item = create_item(contents_root)
			category_tree_item.set_text(0, help_item.category)
			categories[help_item.category] = category_tree_item
		var new_parent = categories[help_item.category]
		var tree_item = create_item(new_parent)
		tree_item.set_text(0, help_item.title)
		tree_item.set_metadata(0, help_item)

# item selected (if the TreeItem is set to selectable, clicking it will fire this signal)
func _on_tree_item_selected():
	# Get the node from the selected tree_item
	if get_selected().get_metadata(0) == null:
		return
	var selected_node = get_selected().get_metadata(0)
	help_contents_item_selected.emit(selected_node)

