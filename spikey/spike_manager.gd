extends Node2D

@export var spike_scene: PackedScene
# @onready var screen_size = get_viewport_rect().size


var spikes := []
var spawn_timer := 0.0
var spawn_interval := 2.0

func _ready():
	spawn_timer = spawn_interval
	spawn_spike()

func _process(delta):
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = spawn_interval
		spawn_spike()

func spawn_spike():
	var spike = spike_scene.instantiate()
	add_child(spike)
	spikes.append(spike)
	var screen_size = get_viewport_rect().size
	var spike_x = randf_range(0, screen_size.x)
	var spike_y = randf_range(0, screen_size.y)
	spike.position = Vector2(spike_x, spike_y)
