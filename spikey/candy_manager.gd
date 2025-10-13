extends Node2D
const TILE_SIZE = preload("res://spikey/constants.gd").TILE_SIZE
const CANDY_GROUP = preload("res://spikey/constants.gd").CANDY_GROUP

@export var candy_scene: PackedScene
# @onready var screen_size = get_viewport_rect().size

var candy = null;

func spawn():
	if candy and is_instance_valid(candy):
		candy.queue_free()
	candy = candy_scene.instantiate()
	add_child(candy)
	candy.add_to_group(CANDY_GROUP)

	var screen_size = get_viewport_rect().size
	var x = randf_range(TILE_SIZE * 2, screen_size.x - TILE_SIZE * 2)
	var y = randf_range(TILE_SIZE * 2, screen_size.y - TILE_SIZE * 2)
	candy.position = Vector2(x, y)
