extends Node
class_name GameScript

# sprite functions

#BlockIt_CannotUse
var _SPRITE : GameSprite

func move(x, y):
	_SPRITE.rect_global_position = Vector2(x, y)
	
func rotate(deg):
	_SPRITE.rect_rotation = deg
