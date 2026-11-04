extends Node


func compile(src:String, sprite:GameSprite, index:int):
	var code = src
	
	var stripped = src.strip_edges()
	
	if not stripped.begins_with("extends"):
		code = "extends GameScript\n\n" + src
	
	var script = GDScript.new()
	script.source_code = code
	var error = script.reload()
	if error != OK:
		pass
	CompilerGlobals.scripts[index] = script
