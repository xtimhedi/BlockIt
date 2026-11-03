extends HSplitContainer

var _last_width = 0.0

func _ready():
	_last_width = get_viewport().size.x
	# Listen for root window size/maximize events
	get_tree().get_root().connect("size_changed", self, "_on_window_resized")

func _on_window_resized():
	var current_width = get_viewport().size.x
	var delta = current_width - _last_width
	
	if delta != 0:
		# Counteract the window resize so the right panel retains its exact width
		split_offset += int(delta)
		_last_width = current_width
