extends CharacterBody2D

const GRAVITY = 1400
const JUMP_FORCE = -500
const MIN_ROTATION = deg_to_rad(-30)  # max upward
const MAX_ROTATION = deg_to_rad(60)   # max downward
const ROTATION_SPEED = 16             # higher = snappier
const FLAPPY_X = 100
const TARGET_ANGLE_PER_VY = 0.001      # higher = cap out angle at lower vy
var died = 0

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	position.x = FLAPPY_X

	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE

	#move_and_slide()
	var collision = move_and_collide(velocity * delta)
	if collision:
		die()

	# Rotate based on falling speed
	var target_rotation = clamp(velocity.y * TARGET_ANGLE_PER_VY, MIN_ROTATION, MAX_ROTATION)
	rotation = lerp_angle(rotation, target_rotation, ROTATION_SPEED * delta)

func die():
	died += 1
	print("died ", died)
