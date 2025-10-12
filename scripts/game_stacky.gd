extends Node2D

const GRAVITY = 600
const initial_forward_speed = 250
var forward_speed = initial_forward_speed
var bg_scroll_speed: float = 250.0
var scroll_offset: float = 0.0
@onready var screen_size = get_viewport_rect().size
@onready var bird_body = $Bird
@onready var bird_sprite = $Bird/BirdSprite
@onready var bird_base_y = screen_size.y - 550
#@onready var block_height = get_block_height()
#@onready var half_block_height = block_height / 2
const BLOCK_HEIGHT = preload("res://scripts/stacky_constants.gd").BLOCK_HEIGHT
const HALF_BLOCK_HEIGHT = BLOCK_HEIGHT / 2
@onready var camera = $Camera2D

var block_scene = preload("res://scenes/stacky_block.tscn")
var score := 0

@onready var score_label: Label = $UI/ScoreLabel

@onready var debug_label: Label = $UI/DebugLabel


func _ready():
	bird_body.position.y = bird_base_y
	bird_body.position.x = 0
	update_score()

func _process(delta):
	scroll_offset += bg_scroll_speed * delta
	camera.position.x = bird_body.position.x - 100
	camera.position.y = 0
	$FloorSprite.region_rect.position.x = scroll_offset
	$FloorSprite.position.x = bird_body.position.x

	update_score()

func _on_die():
	score = 0
	forward_speed = initial_forward_speed
	update_score()

func get_block_height():
		var block_body = block_scene.instantiate()
		var sprite = block_body.get_node("Sprite2D") # Adjust path as needed
		var height = sprite.texture.get_height() * sprite.scale.y
		print("sprite scale ", sprite.scale.y, " height ", height)
		print("body scale ", block_body.scale)
		block_body.queue_free() # Don’t keep it in the scene
		return height

func add_block():
	var bird_y = bird_body.global_position.y
	await get_tree().physics_frame # let the space update
	var block_body = block_scene.instantiate()
	#block.position = Vector2(0, BLOCK_HEIGHT * ($BlockStack.get_child_count() + 1))
	#block_body.global_position.y = bird_body.global_position.y
	#block_body.position.y = bird_body.position.y + BLOCK_HEIGHT
	#block_body.position.x = bird_body.position.x
	#block_body.position.x = 0
	#block.position.x = bird_body.position.x
	#block_body.global_position.y = bird_body.global_position.y
	block_body.global_position.y = bird_y
	#block_body.global_position.x = 0
	#block_body.velocity.y = 0
	print("blockb y ", block_body.global_position.y)
	#block.global_position.y = bird_body.global_position.y + BLOCK_HEIGHT * 1.3
	#block.position.y = 400 - $BlockStack.get_child_count() * BLOCK_HEIGHT

	$BlockStack.add_child(block_body)

func update_score():
	score_label.text = "Score: %d" % score

func yi_to_y(yi):
	return screen_size.y - BLOCK_HEIGHT * yi

func y_to_yi(y):
	return int((screen_size.y - y) / BLOCK_HEIGHT)

func _physics_process(delta):
	#bird_body.velocity.x = forward_speed
	bird_body.velocity.y += GRAVITY * delta

	land_bird_on_stack()

	$BlockStack.position.x = bird_body.position.x
	var bird_at = int(bird_body.position.x / BLOCK_HEIGHT)
	#debug_label.text = str(bird_at) + " " + str($Level.index_to_heights.get(bird_at, [])) + " | Score: " + str(score)
	var is_new_xi = false
	if $Level.bird_at != bird_at:
		is_new_xi = true
	$Level.bird_at = bird_at
	var bird_yi = y_to_yi(bird_body.position.y)
	if is_new_xi:
		if bird_at % 4 == 0:
			score += 1
		if score % 10 == 9:
			forward_speed += 20

	# Remove stack blocks that are at the same y as the level chunk at bird_at
	var level_chunk_heights = $Level.index_to_heights.get(bird_at, [])
	if level_chunk_heights.size() > 0:
		var floor_yi = level_chunk_heights[0]
		var floor_chunk_y = screen_size.y - BLOCK_HEIGHT * level_chunk_heights[0]
		var blocks_to_remove := []
		for block_body in $BlockStack.get_children():
			# Compare y with some tolerance for float precision
			if abs(block_body.position.y - floor_chunk_y) < 1.0:
				blocks_to_remove.append(block_body)
		for block in blocks_to_remove:
			block.queue_free()
	
		# Is bird above floor
		#var bird_bottom_y_edge = bird_body.position.y + BLOCK_HEIGHT * 1.1
		#debug_label.text = "bird_body_y=%s, floor_y=%s" % [bird_body.position.y  + BLOCK_HEIGHT, floor_chunk_y]
		# debug_label.text = "%.2f, %.2f" % [bird_body.position.y, floor_chunk_y]
		# debug_label.text = "%.2f, %.2f" % [bird_yi, floor_yi]
		if bird_body.position.y + BLOCK_HEIGHT >= floor_chunk_y:
			bird_body.velocity.y = 0
			
		if bird_yi <= floor_yi:
			if is_new_xi:
				_on_die()
			bird_body.position.y = floor_chunk_y - BLOCK_HEIGHT - 1
			bird_body.velocity.y = 0

	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("tap"):
		add_block()
		bird_body.global_position.y -= BLOCK_HEIGHT
		bird_body.velocity.y = 0
		bird_sprite.sprite_frames.set_animation_loop("flap", false)
		bird_sprite.play("flap")
		print("bird ", bird_body.global_position.y)

	for block_body in $BlockStack.get_children():
		block_body.velocity.x = 0
		block_body.velocity.y += GRAVITY * delta
		block_body.position.x = 0
		block_body.move_and_slide()
		block_body.position.x = 0

	# Important to update the position at the end to give the rest of the logic
	# the ability to zero out the velocities
	bird_body.position.x += forward_speed * delta
	bird_body.position.y += bird_body.velocity.y * delta

func land_bird_on_stack():
	var floor_y = screen_size.y - 100 # Bird height above ground
	if bird_body.position.y >= floor_y:
		bird_body.position.y = floor_y
		bird_body.velocity.y = 0
		return
	
	# Check if bird is on top of any stack block
	for block_body in $BlockStack.get_children():
		# Check if bird is above the block and close enough
		var bird_bottom = bird_body.position.y + HALF_BLOCK_HEIGHT # Half bird height
		var block_top = block_body.position.y - HALF_BLOCK_HEIGHT # Half block height
		
		if bird_bottom >= block_top:
			bird_body.position.y = block_top - HALF_BLOCK_HEIGHT
			bird_body.velocity.y = 0
			# Check horizontal collision
			#var bird_left = bird_body.position.x - 57.5  # Half bird width
			#var bird_right = bird_body.position.x + 57.5
			#var block_left = block_body.position.x - 32   # Half block width
			#var block_right = block_body.position.x + 32
			
			#if bird_right > block_left and bird_left < block_right:
				## Bird is landing on block, stop falling
				#if bird_body.velocity.y > 0:
					#bird_body.velocity.y = 0
					#bird_body.position.y = block_top - 28
				#return  # Found a landing spot, no need to check further
	
	# Check if bird is on top of any level chunk
	#for chunk in $Level.get_children():
		#var chunk_sprite = chunk.get_node("Sprite2D")
		#var chunk_body = chunk.get_node("StaticBody2D")
		# Check if bird is above the chunk and close enough
		#var bird_bottom = bird_body.position.y + HALF_BLOCK_HEIGHT # Half bird height
		#var chunk_top = chunk.position.y - HALF_BLOCK_HEIGHT # Half chunk height
		
		#if bird_bottom >= chunk_top:
			## Check horizontal collision
			#bird_body.position.y = chunk_top - HALF_BLOCK_HEIGHT
	
	# If bird didn't land on anything, check if it's hitting the level floor


func spawn_block():
	pass
	#var pipe = pipe_scene.instantiate()
	#var gap = -randf_range(gap_min, gap_max)
	#pipe.find_child("TopPipe").position.y = gap
	#pipe.passed_pipe.connect(_on_passed_pipe)
	#add_child(pipe)
	#var pipe_y = randf_range(pipe_min_y - gap, pipe_max_y)
	#pipe.position = Vector2(pipe_spawn_x, pipe_y)
	#pipes.append(pipe)
