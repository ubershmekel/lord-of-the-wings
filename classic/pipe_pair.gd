extends Node2D
signal passed_pipe

func _ready():
	$ScoreZone.body_entered.connect(_on_score_zone_entered)

func _on_score_zone_entered(body):
	if body.name == "Bird":  # or check by group or script type
		emit_signal("passed_pipe")
		$ScoreZone.queue_free()  # prevent double-counting
