class_name HelpContents
extends Tree

var categories = {}
signal help_contents_item_selected(help_item: HelpItem)
var contents_root: TreeItem

func _init():
	var test_root = create_item()
	var test_item = create_item(test_root)
	test_item.set_text(0, "Test Category")

# Connect signals from the Tree
func _ready():
	item_selected.connect(_on_tree_item_selected)
	item_edited.connect(_on_tree_item_edited)
	

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
			category_tree_item.set_text(0,help_item.category)
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


# Name change (if the TreeItem is set to editable, clicking it lets you change the TreeItem's label)
# Here we use the updated label to change the name of the node represented by the tree_item
func _on_tree_item_edited():
	if get_edited_column() == 0:
		if get_edited().get_metadata(0) == null:
			return
		var edited_node = get_edited().get_metadata(0)
		var new_name = get_edited().get_text(0)
		edited_node.name = new_name
