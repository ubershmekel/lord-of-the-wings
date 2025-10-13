extends StaticBody2D
@export var scroll_speed: float = 150.0
var scroll_offset: float = 0.0

func _process(delta):
	scroll_offset += scroll_speed * delta
	$FloorSprite.region_rect.position.x = scroll_offset
