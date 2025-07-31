extends Node2D

@export var pipe_scene: PackedScene
@export var spawn_interval: float = 3
@export var pipe_spawn_x: float = 90
@export var pipe_min_y: float = 10
@export var pipe_max_y: float = 270
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
	var gap = -randf_range(gap_min, gap_max)
	pipe.find_child("TopPipe").position.y = gap
	add_child(pipe)
	var pipe_y = randf_range(pipe_min_y - gap, pipe_max_y)
	pipe.position = Vector2(pipe_spawn_x, pipe_y)
	pipes.append(pipe)
