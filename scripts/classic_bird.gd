extends CharacterBody2D

const GRAVITY = 1400
const JUMP_FORCE = -500
const MIN_ROTATION = deg_to_rad(-30)  # max upward
const MAX_ROTATION = deg_to_rad(60)   # max downward
const ROTATION_SPEED = 16             # higher = snappier
const FLAPPY_X = 100
const TARGET_ANGLE_PER_VY = 0.001      # higher = cap out angle at lower vy

@onready var screen_size = get_viewport_rect().size
@onready var bottom_limit = screen_size.y
@onready var bird_sprite = $BirdSprite
signal scored
signal died

func _ready():
	bird_sprite.play("idle")
	bird_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	position.x = FLAPPY_X

	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("tap"):
		velocity.y = JUMP_FORCE
		bird_sprite.sprite_frames.set_animation_loop("flap", false)
		bird_sprite.play("flap")

	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name == "PipeBody":
			die()
		if collider.name == "ScoreZone":
			score()
			collider.queue_free()


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
