extends Node2D

@export var spike_scene: PackedScene
@onready var screen_size = get_viewport_rect().size
const TILE_SIZE = preload("res://spikey/constants.gd").TILE_SIZE
const SPIKE_GROUP = preload("res://spikey/constants.gd").SPIKE_GROUP


var spawn_timer := 0.0
var spawn_interval := 2.0
var spawn_probability := 0.15

# Store previously spawned spikes for clearing
var spawned_spike_instances := []

func _ready():
	# Initial spawn
	spawn_timer = spawn_interval
	spawn_spikes()

func _process(delta):
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = spawn_interval
		# Clear old spikes before spawning new ones
		clear_spikes()
		spawn_spikes()

func clear_spikes():
	for spike in spawned_spike_instances:
		if is_instance_valid(spike):
			spike.queue_free()
	spawned_spike_instances.clear()

func instantiate_spike():
	var spike = spike_scene.instantiate()
	add_child(spike)
	spawned_spike_instances.append(spike)
	# for collision
	spike.add_to_group(SPIKE_GROUP)
	return spike
	

func spawn_spikes():
	# Top wall
	var top_y = TILE_SIZE
	var num_slots_x = int(screen_size.x / TILE_SIZE) - 2 # Exclude corners
	for i in range(num_slots_x):
		if randf() < spawn_probability:
			var spike = instantiate_spike()
			spike.position = Vector2(TILE_SIZE + (i * TILE_SIZE), top_y)
			spike.rotation = deg_to_rad(90) # Pointing down

	# Bottom wall
	var bottom_y = screen_size.y - TILE_SIZE
	for i in range(num_slots_x): # Same number of slots as top wall
		if randf() < spawn_probability:
			var spike = instantiate_spike()
			spike.position = Vector2(TILE_SIZE + (i * TILE_SIZE), bottom_y)
			spike.rotation = deg_to_rad(270) # Pointing up

	# Left wall
	var left_x = TILE_SIZE
	var num_slots_y = int(screen_size.y / TILE_SIZE) - 2 # Exclude corners
	for i in range(num_slots_y):
		if randf() < spawn_probability:
			var spike = instantiate_spike()
			spike.position = Vector2(left_x, TILE_SIZE + (i * TILE_SIZE))
			spike.rotation = deg_to_rad(0) # Pointing right

	# Right wall
	var right_x = screen_size.x - TILE_SIZE
	for i in range(num_slots_y): # Same number of slots as left wall
		if randf() < spawn_probability:
			var spike = instantiate_spike()
			spike.position = Vector2(right_x, TILE_SIZE + (i * TILE_SIZE))
			spike.rotation = deg_to_rad(180) # Pointing left
