extends CharacterBody2D

const GRAVITY = 1200
const JUMP_FORCE = -500
const MAX_ROTATION = deg_to_rad(45)   # max downward
const MIN_ROTATION = deg_to_rad(-20)  # max upward
const ROTATION_SPEED = 12             # higher = snappier
const FLAPPY_X = 100

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	position.x = FLAPPY_X

	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE

	move_and_slide()

	# Rotate based on falling speed
	var target_rotation = clamp(velocity.y * 0.002, MIN_ROTATION, MAX_ROTATION)
	rotation = lerp_angle(rotation, target_rotation, ROTATION_SPEED * delta)
