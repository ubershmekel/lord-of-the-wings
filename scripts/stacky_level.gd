extends Node2D

@onready var screen_size = get_viewport_rect().size
const BLOCK_HEIGHT = preload("res://scripts/stacky_constants.gd").BLOCK_HEIGHT
const HALF_BLOCK_HEIGHT = BLOCK_HEIGHT / 2
const MIN_FLOOR_HEIGHT = 1
const MAX_FLOOR_HEIGHT = 8
const MIN_CEILING_HEIGHT = 10
const MAX_CEILING_HEIGHT = 15
const GENERATE_WHEN_LEFT = 20
const GENERATE_AT_A_TIME = 50
const DELETE_LEFT_OF_BIRD_X = 5
const OBSTACLE_PROBABILITY = 0.1

var level_chunk_scene = preload("res://scenes/stacky_level_chunk.tscn")

@export var bird_at: int = false
# {column_index: [tile_height, ...]}
# {3: [0, 4, 8]}
@export var index_to_heights: Dictionary = {}
@export var index_to_chunks: Dictionary = {}

# blocks_generated_to when 0 or greater points to the last column that has been generated
@export var blocks_generated_to: int = -1
# blocks_exist_from when 0 or greater points to the first column that has been generated
@export var blocks_exist_from: int = -1


func _ready():
	blocks_exist_from = 0
	generate_chunks()

func _process(_delta):
	var remaining_columns = blocks_generated_to - bird_at
	if remaining_columns < GENERATE_WHEN_LEFT:
		# delete old
		for i in range(blocks_exist_from, bird_at - DELETE_LEFT_OF_BIRD_X):
			var chunks = index_to_chunks[i]
			index_to_heights.erase(i)
			index_to_chunks.erase(i)
			for tile in chunks:
				tile.queue_free()
			blocks_exist_from = i + 1

		# generate new chunks
		generate_chunks()

func yi_to_y(yi):
	return screen_size.y - BLOCK_HEIGHT * yi

func y_to_yi(y):
	# This `+HALF_BLOCK_HEIGHT` is critical because we want the middle of the bird
	# to decide which grid cell it's in, not the edge of the bird.
	return int((screen_size.y - y + HALF_BLOCK_HEIGHT) / BLOCK_HEIGHT) 

func _create_chunk(column_index: int, height: int) -> Node2D:
	var chunk = level_chunk_scene.instantiate()
	chunk.position.x = column_index * BLOCK_HEIGHT
	chunk.position.y = yi_to_y(height) # screen_size.y - BLOCK_HEIGHT * height
	add_child(chunk)
	return chunk

func generate_chunks():
	var current_floor_height: int
	var current_ceiling_height: int

	if blocks_generated_to == -1:
		current_floor_height = MIN_FLOOR_HEIGHT
		current_ceiling_height = MAX_CEILING_HEIGHT # Initial ceiling height
	else:
		# Get the floor height of the last generated column
		current_floor_height = index_to_heights[blocks_generated_to][0]
		# Get the ceiling height of the last generated column (assuming it's the second element)
		# This assumes that index_to_heights[blocks_generated_to] will always have at least 2 elements (floor and ceiling)
		current_ceiling_height = index_to_heights[blocks_generated_to][1]


	print("generating chunks starting from floor height: " + str(current_floor_height) + ", ceiling height: " + str(current_ceiling_height))

	for i in range(GENERATE_AT_A_TIME):
		var column_index = blocks_generated_to + 1
		var column_chunks: Array[Node2D] = []
		var column_heights: Array[int] = []

		# randomly go up or down for floor 10% of the time
		if randf() > 0.8:
			if current_floor_height == MIN_FLOOR_HEIGHT:
				current_floor_height += 1
			elif current_floor_height == MAX_FLOOR_HEIGHT:
				current_floor_height -= 1
			else:
				current_floor_height += randi() % 2 * 2 - 1

		# randomly go up or down for ceiling 10% of the time
		if randf() > 0.8:
			if current_ceiling_height == MIN_CEILING_HEIGHT:
				current_ceiling_height += 1
			elif current_ceiling_height == MAX_CEILING_HEIGHT:
				current_ceiling_height -= 1
			else:
				current_ceiling_height += randi() % 2 * 2 - 1
		
		# Ensure ceiling is always above floor with a minimum gap
		if current_ceiling_height - current_floor_height < 5: # Minimum gap of 4 blocks (e.g. 1 floor + 1 gap + 1 obstacle + 1 gap + 1 ceiling = 5)
			current_ceiling_height = current_floor_height + 5

		# Generate floor
		var floor_chunk = _create_chunk(column_index, current_floor_height)
		column_chunks.append(floor_chunk)
		column_heights.append(current_floor_height)

		# Generate ceiling
		var ceiling_chunk = _create_chunk(column_index, current_ceiling_height)
		column_chunks.append(ceiling_chunk)
		column_heights.append(current_ceiling_height)

		# Generate obstacle (middle tile)
		if randf() < OBSTACLE_PROBABILITY:
			# Ensure obstacle doesn't block the path, leave at least 1 empty space below and above
			var obstacle_min_pos = current_floor_height + 2
			var obstacle_max_pos = current_ceiling_height - 2
			if obstacle_max_pos >= obstacle_min_pos: # Check if there's space for an obstacle
				var obstacle_height = randi_range(obstacle_min_pos, obstacle_max_pos)
				var obstacle_chunk = _create_chunk(column_index, obstacle_height)
				column_chunks.append(obstacle_chunk)
				column_heights.append(obstacle_height)

		index_to_heights[column_index] = column_heights
		index_to_chunks[column_index] = column_chunks
		blocks_generated_to = column_index
