extends Node2D
var score = 0

func _ready():
	#$PipeScroller.connect("passed_pipe", scored)
	$Bird.connect("died", died)
	update_score()

func update_score():
	$UI/ScoreLabel.text = "Score: %d" % score

func scored():
	score += 1
	update_score()

func died():
	score = 0
	update_score()
