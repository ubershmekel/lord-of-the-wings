extends Node2D

const GRAVITY = 1000
const FORWARD_SPEED = 150
var scroll_speed: float = 150.0
var scroll_offset: float = 0.0
@onready var screen_size = get_viewport_rect().size
@onready var bird_body = $Bird
@onready var bird_sprite = $Bird/BirdSprite
@onready var bird_base_y = screen_size.y - 550
@onready var block_height = get_block_height()
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
		chunk.position.y = 300
		$Level.add_child(chunk)

func _process(delta):
	scroll_offset += scroll_speed * delta
	$FloorSprite.region_rect.position.x = scroll_offset
	camera.position.x = bird_body.position.x - 100
	camera.position.y = 0


func get_block_height():
	var block = block_scene.instantiate()
	var block_body = block.get_node("BlockBody")
	var sprite = block_body.get_node("Sprite2D")  # Adjust path as needed
	var height = sprite.texture.get_height() * sprite.scale.y
	block.queue_free()  # Don’t keep it in the scene
	return height

func add_block():
	var block = block_scene.instantiate()
	#block.position = Vector2(0, block_height * ($BlockStack.get_child_count() + 1))
	var block_body = block.get_node("BlockBody")
	#block_body.global_position.y = bird_body.global_position.y
	#block_body.position.y = bird_body.position.y + block_height
	#block_body.position.x = bird_body.position.x
	#block_body.position.x = 0
	#block.position.x = bird_body.position.x
	block.global_position.y = bird_body.global_position.y

	$BlockStack.add_child(block)

func _physics_process(delta):
	bird_body.velocity.x = FORWARD_SPEED
	bird_body.velocity.y += GRAVITY * delta
	#$BlockStack.position = $Bird.position
	if $BlockStack.get_child_count() > 0:
		var first_block = $BlockStack.get_child(0)
		var block_body = first_block.get_node("BlockBody")
		#debug_label.text = "%f %f" % [first_block.position.x, first_block.position.y]
		#debug_label.text = "%s\n%s\n%s\n%s" % [$BlockStack.position, first_block.position, block_body.position, bird_body.position]
		#var pos = [bl for bl in $BlockStack.get_children()]
		#debug_label.text = "\n".join([
			
			#$BlockStack.global_position ,
			#block_body.global_position,
			#first_block.global_position,
			#first_block.get_child(0).global_position,
			#bird_body.position
		#])
		
		var positions = [bird_body.global_position]
		for block in $BlockStack.get_children():
			var bbody = block.get_node("BlockBody")
			positions.append(bbody.position)
		debug_label.text = "\n".join(positions)


	if Input.is_action_just_pressed("ui_accept"):
		#print(bird_body.position.x)
		#print(bird_base_y, " ", bird_body.position.y, " ", bird_body.velocity.y)
		bird_body.global_position.y -= block_height * 3
		bird_body.velocity.y = 0
		bird_sprite.sprite_frames.set_animation_loop("flap", false)
		bird_sprite.play("flap")
		add_block()
		
	
	for block in $BlockStack.get_children():
		var block_body = block.get_node("BlockBody")
		block_body.global_position.x = bird_body.global_position.x
		#block.position.x = block_height
		#block_body.velocity.x = FORWARD_SPEED
		block_body.velocity.y += GRAVITY * delta
		block_body.move_and_slide()

	#$BlockStack.position.x = bird_body.position.x
	#print("block.position: ", $BlockStack.position)
	#print("bird_body.position: ", bird_body.position)
	bird_body.move_and_slide()

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
