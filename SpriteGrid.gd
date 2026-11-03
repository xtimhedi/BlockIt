extends GridContainer

# Set this to the minimum width you want each column to be
export(float) var item_min_width = 120.0

func _ready():
	# Connect the window/parent resize signal
	connect("resized", self, "_on_width_changed")
	_on_width_changed()

func _on_width_changed():
	var h_sep = 0
	
	# Proper Godot 3.4 fallback hierarchy
	if has_constant_override("h_separation"):
		h_sep = get_constant("h_separation")
	else:
		h_sep = get_constant("h_separation", "GridContainer")
	
	# Calculate how many columns fit inside the current width
	var available_width = rect_size.x
	var max_cols = int(floor((available_width + h_sep) / (item_min_width + h_sep)))
	
	# Fallback to 1 column to avoid engine calculation crashes
	columns = max(1, max_cols)
