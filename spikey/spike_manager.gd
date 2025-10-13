extends Node2D

@export var spike_scene: PackedScene
@onready var screen_size = get_viewport_rect().size
const TILE_SIZE = preload("res://spikey/constants.gd").TILE_SIZE
const SPIKE_GROUP = preload("res://spikey/constants.gd").SPIKE_GROUP


var spawn_probability := 0.15
var awaiting_spike_spawn := false
var bird_reference = null

# Store previously spawned spikes for clearing
var spawned_spike_instances := []

func _process(delta):
	if awaiting_spike_spawn and bird_reference:
		var bird_x = bird_reference.global_position.x
		var bird_direction = bird_reference.direction
		
		var spawn_condition_met = false

		# Bird is a bit wider than tile size, and we don't want spikes
		# to spawn on it after the wall touch
		const BUFFER = TILE_SIZE * 3
		# If bird is moving right (direction = 1), check left wall
		if bird_direction == 1 and bird_x >= BUFFER:
			spawn_condition_met = true
		# If bird is moving left (direction = -1), check right wall
		elif bird_direction == -1 and bird_x <= (screen_size.x - BUFFER):
			spawn_condition_met = true

		if spawn_condition_met:
			clear_spikes()
			spawn_spikes()
			awaiting_spike_spawn = false # Reset the flag after spawning

func _on_bird_flipped(direction, position):
	awaiting_spike_spawn = true
	# We don't clear spikes here because we want to clear them right before spawning
	# which happens when the position condition is met.

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
