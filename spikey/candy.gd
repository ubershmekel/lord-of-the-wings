extends Area2D
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	# If using AnimatedSprite2D with frames:
	if $AnimatedSprite2D.sprite_frames:
		$AnimatedSprite2D.play()

func _on_body_entered(body: Node) -> void:
	#print("candy collided with ", body)
	if body.name == "Bird":
		body.collect_candy(self)
