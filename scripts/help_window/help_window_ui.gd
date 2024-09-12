class_name HelpWindow
extends Control

@export var help_contents: HelpContents
@export var help_text: RichTextLabel

signal help_window_close_pressed()

const HELP_PAGE_DIR = "res://resources/help_pages/"

func _ready():
	var help_pages = load_help_pages(HELP_PAGE_DIR)
	help_contents.update_tree(help_pages)
	MessageBus.hint_clicked.connect(_on_keyword_clicked)

func load_help_pages(dirname: String) -> Array[HelpItem]:
	var result: Array[HelpItem] = []
	var dir = DirAccess.open(dirname)
	if dir:
		for file_name in dir.get_files():
			var help_item = ResourceLoader.load(dirname + "/" + file_name, "HelpItem")
			if help_item is HelpItem:
				result.append(help_item)
		for sub_dirname in dir.get_directories():
			result.append_array(load_help_pages(dirname + "/" + sub_dirname))
	else:
		push_error("Failed to find help_pages directory")
	return result

func _on_help_contents_item_selected(help_item: HelpItem):
	help_text.clear()
	help_text.append_text("[b]%s[/b]\n\n" % help_item.title)
	help_text.append_text(help_item.content)
	
func _on_keyword_clicked(metadata):
	if help_contents.categories.has(metadata):
		# links to high level category, we're done
		help_contents.set_selected(help_contents.categories[metadata],0)
		return
		
	# search through the tree for the linked page
	var root = help_contents.get_root()
	var target_page: TreeItem = null
	var current_page = root.get_next_in_tree() 
	
	while current_page != root: # we wrapped back to root so stop
		if current_page.get_text(0).to_lower().begins_with(metadata.to_lower()): # use prefix for easier help page writing
			help_contents.set_selected(current_page,0)
			return
		current_page = current_page.get_next_in_tree(true) # true -> wrap
	
	if target_page == null:
		push_warning("BBCode URL tag \"%s\" could not be found in help window contents" % str(metadata))

func _on_help_window_close_button_pressed():
	help_window_close_pressed.emit()

func add_font_size(x:int):
	var font_size = theme.get_font_size("normal_font_size","RichTextLabel")
	theme.set_font_size("normal_font_size","RichTextLabel",font_size + x)
	font_size = theme.get_font_size("mono_font_size","RichTextLabel")
	theme.set_font_size("mono_font_size","RichTextLabel",font_size + x)
	font_size = theme.get_font_size("font_size","Tree")
	theme.set_font_size("font_size","Tree",font_size + x)
	font_size = theme.get_font_size("title_button_font_size","Tree")
	theme.set_font_size("title_button_font_size","Tree",font_size + x)

func _on_zoom_out_button_pressed():
	add_font_size(-1)

func _on_zoom_in_button_pressed():
	add_font_size(1)
