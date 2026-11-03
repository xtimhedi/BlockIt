extends AspectRatioContainer

# Reference the parent split container to adjust its splitter position
onready var v_split = get_parent().get_parent() 

func _ready():
	# Listen for whenever the UI changes or window is resized/maximized
	connect("item_rect_changed", self, "_on_resized")

func _on_resized():
	# Calculate the ideal vertical size required based on the current width
	var ideal_height = rect_size.x / ratio
	
	# Push the parent split container's dividing bar to match our aspect height
	# We add any padding/margins if needed (e.g., from PanelContainer margins)
	var parent_panel_padding = 14 
	v_split.split_offset = int(ideal_height + parent_panel_padding)
