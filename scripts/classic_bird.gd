extends CharacterBody2D

const GRAVITY = 1000
const JUMP_FORCE = -500
const MAX_ROTATION = deg_to_rad(45)   # 45 degrees downward
const MIN_ROTATION = deg_to_rad(-20)  # 20 degrees upward
const ROTATION_SPEED = 8           # higher = snappier

func _physics_process(delta):
	velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE

	move_and_slide()

	# Rotate based on falling speed
	var target_rotation = clamp(velocity.y * 0.002, MIN_ROTATION, MAX_ROTATION)
	rotation = lerp_angle(rotation, target_rotation, ROTATION_SPEED * delta)
