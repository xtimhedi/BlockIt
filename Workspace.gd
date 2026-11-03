extends TabContainer

var Editors = [
	preload("res://MainEditor.tscn")
]

func _ready():
	for e in Editors:
		var editor : PackedScene = e
		add_child(editor.instance())
