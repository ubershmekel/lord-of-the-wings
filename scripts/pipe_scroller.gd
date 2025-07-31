extends Node2D

@export var pipe_scene: PackedScene
@export var spawn_interval: float = 3
@export var pipe_spawn_x: float = 90
@export var pipe_min_y: float = 50
@export var pipe_max_y: float = 250
@export var pipe_vx: float = 25
var pipe_erase_x = -100;
var gap_min = 40
var gap_max = 100

var spawn_timer := 0.0
var pipes := []

func _physics_process(delta):
	for pipe in pipes:
		pipe.position.x -= delta * pipe_vx	
		if pipe.position.x < pipe_erase_x:
			pipe.queue_free()
			pipes.erase(pipe)

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0
		spawn_pipe()
		

func spawn_pipe():
	var pipe = pipe_scene.instantiate()
	pipe.find_child("TopPipe").position.y = -randf_range(gap_min, gap_max)
	add_child(pipe)
	pipe.position = Vector2(pipe_spawn_x, randf_range(pipe_min_y, pipe_max_y))
	pipes.append(pipe)
