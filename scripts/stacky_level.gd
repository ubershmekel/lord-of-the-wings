extends Node2D

@onready var screen_size = get_viewport_rect().size
const BLOCK_HEIGHT = preload("res://scripts/stacky_constants.gd").BLOCK_HEIGHT
const MIN_HEIGHT = 1
const MAX_HEIGHT = 10
const GENERATE_WHEN_LEFT = 20
const GENERATE_AT_A_TIME = 50
const DELETE_LEFT_OF_BIRD_X = 5

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
	generate_chunks(MIN_HEIGHT)

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
		var last_column = index_to_heights[blocks_generated_to]
		var last_floor_height = last_column[0]
		generate_chunks(last_floor_height)

func generate_chunks(start_height: int = 0):
	print("generating chunks at start_height: " + str(start_height))
	var cur_height = start_height
	for i in range(GENERATE_AT_A_TIME):
		var index = blocks_generated_to + 1
		# randomly go up or down 10% of the time
		if randf() > 0.7:
			# height change
			if cur_height == MIN_HEIGHT:
				cur_height += 1
			elif cur_height == MAX_HEIGHT:
				cur_height -= 1
			else:
				# random +1 or -1
				cur_height += randi() % 2 * 2 - 1

		var chunk = level_chunk_scene.instantiate()
		chunk.position.x = index * BLOCK_HEIGHT
		chunk.position.y = screen_size.y - BLOCK_HEIGHT * cur_height
		index_to_heights[index] = [cur_height]
		index_to_chunks[index] = [chunk]
		add_child(chunk)
		blocks_generated_to = index
