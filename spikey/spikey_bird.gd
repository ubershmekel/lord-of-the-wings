extends CharacterBody2D

const GRAVITY = 1400
const JUMP_FORCE = -500
const MIN_ROTATION = deg_to_rad(-30)  # max upward
const MAX_ROTATION = deg_to_rad(60)   # max downward
const ROTATION_SPEED = 16             # higher = snappier
const FLAPPY_X = 100
const TARGET_ANGLE_PER_VY = 0.001      # higher = cap out angle at lower vy
const FORWARD_SPEED = 200

@onready var screen_size = get_viewport_rect().size
@onready var bottom_limit = screen_size.y
@onready var bird_sprite = $BirdSprite
var direction = 1
var collisions = 0
signal scored
signal died

func _ready():
	bird_sprite.play("idle")
	bird_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	$"../UI/DebugLabel".text = "%.2f" % collisions

	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("tap"):
		velocity.y = JUMP_FORCE
		bird_sprite.sprite_frames.set_animation_loop("flap", false)
		bird_sprite.play("flap")

	var flipped = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name == "Right":
			flipped = true
			direction = -1
		if  collider.name == "Left":
			flipped = true
			direction = 1
			
		if collider.name == "ScoreZone":
			score()
			collider.queue_free()

	if flipped:
		collisions += 1
	velocity.y += GRAVITY * delta
	velocity.x = FORWARD_SPEED * direction
	move_and_slide()

	if is_on_floor():
		velocity.y = 0

	# Rotate based on falling speed
	var target_rotation = clamp(velocity.y * TARGET_ANGLE_PER_VY, MIN_ROTATION, MAX_ROTATION)
	rotation = lerp_angle(rotation, target_rotation, ROTATION_SPEED * delta)

func score():
	print("scored")
	emit_signal("scored")

func die():
	emit_signal("died")

func _on_animation_finished():
	#print("anim", anim_name)
	#if anim_name == "flap":
	bird_sprite.sprite_frames.set_animation_loop("idle", true)
	bird_sprite.play("idle")
