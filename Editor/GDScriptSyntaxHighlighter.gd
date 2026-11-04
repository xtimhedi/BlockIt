extends TextEdit
class_name CodeEdit

# Autocomplete storage
var suggestions_list: Array = []
var active_word: String = ""
var completion_popup: ItemList

var default_text = """func start():
	pass

func update(delta):
	pass
"""

func _ready() -> void:
	# 1. Base editor behaviors
	syntax_highlighting = true
	show_line_numbers = true
	draw_tabs = true
	
	# 2. Build and style the visual popup
	setup_popup_ui()
	
	# 3. Hook up listener
	connect("text_changed", self, "_on_text_changed")
	
	# 4. Initialize lookups
	setup_highlighter_rules()
	
	text = default_text
	
	# Force syntax parsing on pre-populated text blocks
	var current_text = text
	text = ""
	text = current_text

func setup_popup_ui() -> void:
	completion_popup = ItemList.new()
	add_child(completion_popup)
	completion_popup.visible = false
	
	# Size restraints
	completion_popup.rect_min_size = Vector2(200, 140)
	completion_popup.select_mode = ItemList.SELECT_SINGLE
	
	# Force a clear visible background panel so it doesn't blend in
	var flat_style = StyleBoxFlat.new()
	flat_style.bg_color = Color("#20232d") # Dark charcoal editor color
	flat_style.set_border_width_all(1)
	flat_style.border_color = Color("#3a3f52")
	completion_popup.add_stylebox_override("bg", flat_style)
	
	completion_popup.connect("item_activated", self, "_on_item_selected")

func setup_highlighter_rules() -> void:
	clear_colors()
	
	var color_keyword = Color("#ff7085") # Pinkish Red
	var color_builtin = Color("#ffeb70") # Bright Yellow
	
	add_color_region("#", "", Color("#7a839e"), true)
	add_color_region('"', '"', Color("#ebe0a0"), false)
	
	# Target vocabulary matching your screen text exactly
	register_term("func", color_keyword)
	register_term("pass", color_keyword)
	
	register_term("start():", color_builtin)
	register_term("update(delta):", color_builtin)
	
	register_term("if", color_keyword)
	register_term("else", color_keyword)
	
	register_term("move(x, y)", color_builtin)
	register_term("rotate(deg)", color_builtin)

func register_term(term_name: String, highlight_color: Color) -> void:
	add_keyword_color(term_name, highlight_color)
	if not suggestions_list.has(term_name):
		suggestions_list.append(term_name)

func _on_text_changed() -> void:
	var line_text = get_line(cursor_get_line())
	var col = cursor_get_column()
	
	if col <= 0:
		completion_popup.visible = false
		return
		
	var text_before_cursor = line_text.substr(0, col)
	var regex = RegEx.new()
	regex.compile("[a-zA-Z0-9_]+$") 
	var result = regex.search(text_before_cursor)
	
	if result:
		active_word = result.get_string()
		if active_word.length() >= 1:
			update_and_show_popup(active_word)
			return
			
	completion_popup.visible = false

func update_and_show_popup(filter_prefix: String) -> void:
	completion_popup.clear()
	
	var matches = []
	for term in suggestions_list:
		if term.to_lower().begins_with(filter_prefix.to_lower()):
			matches.append(term)
			
	if matches.empty():
		completion_popup.visible = false
		return
		
	for item in matches:
		completion_popup.add_item(item)
		
	completion_popup.select(0)
	
	# Position dropdown right beneath text insertion row
	var cursor_pixel_pos = get_pos_at_line_column(cursor_get_line(), cursor_get_column())
	completion_popup.rect_position = cursor_pixel_pos + Vector2(25, 22)
	completion_popup.visible = true
	completion_popup.raise()

func _on_item_selected(index: int) -> void:
	var chosen_text = completion_popup.get_item_text(index)
	var current_line = cursor_get_line()
	var current_col = cursor_get_column()
	
	var start_col = max(0, current_col - active_word.length())
	
	select(current_line, start_col, current_line, current_col)
	insert_text_at_cursor(chosen_text)
	
	completion_popup.visible = false
	grab_focus()

func _input(event: InputEvent) -> void:
	if not completion_popup.visible or not has_focus():
		return
		
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ESCAPE or event.scancode == KEY_SPACE:
			completion_popup.visible = false
			if event.scancode == KEY_ESCAPE:
				get_tree().set_input_as_handled()
			return
			
		elif event.scancode == KEY_TAB or event.scancode == KEY_ENTER:
			var selected = completion_popup.get_selected_items()
			if selected.size() > 0:
				_on_item_selected(selected[0])
			get_tree().set_input_as_handled()
			return
			
		elif event.is_action_pressed("ui_up", true):
			var selected = completion_popup.get_selected_items()
			if selected.size() > 0:
				var prev_idx = selected[0] - 1
				if prev_idx >= 0:
					completion_popup.select(prev_idx)
					completion_popup.ensure_current_is_visible()
			get_tree().set_input_as_handled()
			return
			
		elif event.is_action_pressed("ui_down", true):
			var selected = completion_popup.get_selected_items()
			if selected.size() > 0:
				var next_idx = selected[0] + 1
				if next_idx < completion_popup.get_item_count():
					completion_popup.select(next_idx)
					completion_popup.ensure_current_is_visible()
			get_tree().set_input_as_handled()
			return
