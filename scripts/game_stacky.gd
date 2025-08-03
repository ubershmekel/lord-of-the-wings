extends Node2D

const GRAVITY = 1000
var scroll_speed: float = 150.0
var scroll_offset: float = 0.0
@onready var screen_size = get_viewport_rect().size
@onready var bird_body = $Bird
@onready var bird_sprite = $Bird/BirdSprite
@onready var bird_base_y = screen_size.y - 550
@onready var block_height = get_block_height()
@onready var camera = $Camera2D

var block_scene = preload("res://scenes/stacky_block.tscn")
const FORWARD_SPEED = 150

func _ready():
	bird_body.position.y = bird_base_y
	bird_body.position.x = 0

func _process(delta):
	scroll_offset += scroll_speed * delta
	$FloorSprite.region_rect.position.x = scroll_offset
	camera.position.x = bird_body.position.x - 100
	camera.position.y = 0


func get_block_height():
	var block = block_scene.instantiate()
	var sprite = block.get_node("Sprite2D")  # Adjust path as needed
	var block_height = sprite.texture.get_height() * sprite.scale.y
	block.queue_free()  # Don’t keep it in the scene
	return block_height

func add_block():
	var block = block_scene.instantiate()
	block.position = Vector2(0, block_height * ($BlockStack.get_child_count() + 1))
	$BlockStack.add_child(block)
	print(block)

func _physics_process(delta):
	bird_body.velocity.x = FORWARD_SPEED
	bird_body.velocity.y += GRAVITY * delta
	$BlockStack.position = $Bird.position
	if Input.is_action_just_pressed("ui_accept"):
		add_block()
		print(bird_base_y, " ", bird_body.position.y, " ", bird_body.velocity.y)
		bird_body.position.y -= block_height
		bird_body.velocity.y = 0
		bird_sprite.sprite_frames.set_animation_loop("flap", false)
		bird_sprite.play("flap")
		
	
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
