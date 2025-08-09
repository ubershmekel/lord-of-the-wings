extends Node2D

const GRAVITY = 600
const FORWARD_SPEED = 150
var scroll_speed: float = 150.0
var scroll_offset: float = 0.0
@onready var screen_size = get_viewport_rect().size
@onready var bird_body = $Bird
@onready var bird_sprite = $Bird/BirdSprite
@onready var bird_base_y = screen_size.y - 550
@onready var block_height = get_block_height()
@onready var half_block_height = block_height / 2
@onready var camera = $Camera2D

var block_scene = preload("res://scenes/stacky_block.tscn")
var level_chunk_scene = preload("res://scenes/stacky_level_chunk.tscn")

@onready var debug_label: Label = $UI/DebugLabel

func _ready():
	bird_body.position.y = bird_base_y
	bird_body.position.x = 0
	
	for i in range(100):
		var chunk = level_chunk_scene.instantiate()
		chunk.position.x = i * block_height
		chunk.position.y = screen_size.y - block_height
		$Level.add_child(chunk)

func _process(delta):
	scroll_offset += scroll_speed * delta
	camera.position.x = bird_body.position.x - 100
	camera.position.y = 0
	$FloorSprite.region_rect.position.x = scroll_offset
	$FloorSprite.position.x = bird_body.position.x 


func get_block_height():
	var block_body = block_scene.instantiate()
	var sprite = block_body.get_node("Sprite2D")  # Adjust path as needed
	var height = sprite.texture.get_height() * sprite.scale.y
	print("sprite scale ", sprite.scale.y, " height ", height)
	print("body scale ", block_body.scale)
	block_body.queue_free()  # Don’t keep it in the scene
	return height

func add_block():
	var bird_y = bird_body.global_position.y
	await get_tree().physics_frame  # let the space update
	var block_body = block_scene.instantiate()
	#block.position = Vector2(0, block_height * ($BlockStack.get_child_count() + 1))
	#block_body.global_position.y = bird_body.global_position.y
	#block_body.position.y = bird_body.position.y + block_height
	#block_body.position.x = bird_body.position.x
	#block_body.position.x = 0
	#block.position.x = bird_body.position.x
	#block_body.global_position.y = bird_body.global_position.y
	block_body.global_position.y = bird_y
	#block_body.global_position.x = 0
	#block_body.velocity.y = 0
	print("blockb y ", block_body.global_position.y)
	#block.global_position.y = bird_body.global_position.y + block_height * 1.3
	#block.position.y = 400 - $BlockStack.get_child_count() * block_height

	$BlockStack.add_child(block_body)

func _physics_process(delta):
	#bird_body.velocity.x = FORWARD_SPEED
	bird_body.velocity.y += GRAVITY * delta
	bird_body.position.x += FORWARD_SPEED * delta
	bird_body.position.y += bird_body.velocity.y * delta
	
	# Check if bird is on top of any block or level chunk
	check_bird_landing()
	
	#bird_body.position.y > floor
	
	$BlockStack.position.x = bird_body.position.x
	#$BlockStack.position = $Bird.position
	if $BlockStack.get_child_count() > 0:
		var first_block = $BlockStack.get_child(0)
		#debug_label.text = "%f %f" % [first_block.position.x, first_block.position.y]
		#debug_label.text = "%s\n%s\n%s\n%s" % [$BlockStack.position, first_block.position, block_body.position, bird_body.position]
		#var pos = [bl for bl in $BlockStack.get_children()]
		debug_label.text = "\n".join([
			$BlockStack.global_position,
			first_block.global_position,
			first_block.get_child(0).global_position,
			#bird_body.position
		])
		
		var positions = [bird_body.global_position]
		for block_body in $BlockStack.get_children():
			positions.append(block_body.global_position)
		debug_label.text = "\n".join(positions)


	if Input.is_action_just_pressed("ui_accept"):
		#print(bird_body.position.x)
		#print(bird_base_y, " ", bird_body.position.y, " ", bird_body.velocity.y)
		add_block()
		bird_body.global_position.y -= block_height
		bird_body.velocity.y = 0
		bird_sprite.sprite_frames.set_animation_loop("flap", false)
		bird_sprite.play("flap")
		print("bird ", bird_body.global_position.y)
		
	
	for block_body in $BlockStack.get_children():
		#block_body.global_position.x = bird_body.global_position.x
		#block.position.x = block_height
		block_body.velocity.x = 0
		block_body.velocity.y += GRAVITY * delta
		#block_body.position.y += block_body.velocity.y * delta
		block_body.position.x = 0
		block_body.move_and_slide()
		block_body.position.x = 0

	#$BlockStack.position.x = bird_body.position.x
	#print("block.position: ", $BlockStack.position)
	#print("bird_body.position: ", bird_body.position)
	#bird_body.move_and_slide()

func check_bird_landing():
	# Check if bird is on top of any block
	for block_body in $BlockStack.get_children():
		
		# Check if bird is above the block and close enough
		var bird_bottom = bird_body.position.y + half_block_height  # Half bird height
		var block_top = block_body.position.y - half_block_height   # Half block height
		
		if bird_bottom >= block_top:
			bird_body.position.y = block_top - half_block_height
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
	for chunk in $Level.get_children():
		var chunk_sprite = chunk.get_node("Sprite2D")
		var chunk_body = chunk.get_node("StaticBody2D")
		
		# Check if bird is above the chunk and close enough
		var bird_bottom = bird_body.position.y + half_block_height  # Half bird height
		var chunk_top = chunk.position.y - half_block_height   # Half chunk height
		
		if bird_bottom >= chunk_top:
			# Check horizontal collision
			bird_body.position.y = chunk_top - half_block_height
	
	# If bird didn't land on anything, check if it's hitting the level floor
	var floor_y = screen_size.y - 100  # Bird height above ground
	if bird_body.position.y >= floor_y:
		bird_body.position.y = floor_y
		bird_body.velocity.y = 0

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
