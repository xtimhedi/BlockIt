extends TextureRect
class_name GameSprite

export var source : String

var scriptIndex : int

func _ready():
	scriptIndex = CompilerGlobals.nextIndex
	CompilerGlobals.incrementIndex()

func _mRun():
	if CompilerGlobals.scripts[scriptIndex].has_method("start"):
		CompilerGlobals.scripts[scriptIndex].start()
		
func _mUpdate():
	if CompilerGlobals.scripts[scriptIndex].has_method("update"):
		CompilerGlobals.scripts[scriptIndex].update() 
