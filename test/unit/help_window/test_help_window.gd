extends GutTest

@onready var help_window_scene = preload("res://scenes/help_window/help_window_ui.tscn")

var help_window: HelpWindow
var help_items: Array[HelpItem]

signal help_text_updated

func before_each():
	help_window = help_window_scene.instantiate() as HelpWindow
	add_child(help_window)
	if not help_window.is_node_ready():
		await help_window.ready
	help_items = help_window.load_help_pages(HelpWindow.HELP_PAGE_DIR)

func test_links():
	# test that all titles work
	for help_item in help_items:
		help_window._on_keyword_clicked(help_item.title)
		assert(check_window_matches_item(help_item))
	for help_item in help_items:
		help_window._on_keyword_clicked(help_item.title.to_lower())
		assert(check_window_matches_item(help_item))
	
	# check that random url mistake doesnt mess anything up
	var prev_text = help_window.help_text.text.hash()
	help_window._on_keyword_clicked("gibberish")
	assert_eq(help_window.help_text.text.hash(), prev_text, "Help window changed when gibberish url clicked")

func check_window_matches_item(help_item: HelpItem) -> bool:
	var help_text = RichTextLabel.new()
	add_child_autoqfree(help_text)
	help_text.bbcode_enabled = true
	help_text.clear()
	help_text.append_text("[b]%s[/b]\n\n" % help_item.title)
	help_text.append_text(help_item.content)
	var result = false
	# have to use get_parsed_text() due to https://github.com/godotengine/godot/issues/94630
	if not assert_eq(help_window.help_text.get_parsed_text(), help_text.get_parsed_text(), 
						"Window did not change correctly on helplink click"):
		result = true
	help_text.queue_free()
	return result

func test_help_page_loading():
	var dir = DirAccess.open("res://resources/help_pages")
	if not dir:
		fail_test("Couldn't find help pages directory")
		return
	assert_not_null(help_items, "Null result from help_window.load_help_pages()")
	assert_ne(len(help_items), 0, "Empty result from help_window.load_help_pages()")

func test_contents():
	var help_contents = help_window.help_contents
	var root = help_contents.get_root()
	assert_not_null(root, "Null help contents tree root")
	var target_page: TreeItem = null
	var current_page = root.get_next_in_tree() 
	
	while current_page != root: # we wrapped back to root so stop
		var metadata = current_page.get_metadata(0)
		if metadata == null:
			# category page, make sure it has children
			var child_count = current_page.get_child_count()
			assert_ne(child_count, 0, "Empty help category")
		else:
			# help page, make sure its working
			assert_is(metadata, HelpItem, "Help category contains non-help item")
			metadata = metadata as HelpItem
			assert_ne(metadata.content, "", "Empty help page")
			assert_ne(metadata.title, "", "Empty help page title")
		current_page = current_page.get_next_in_tree(true) # true -> wrap

func after_each():
	help_window.queue_free()
	help_items = []
