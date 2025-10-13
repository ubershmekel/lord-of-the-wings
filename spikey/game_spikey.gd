extends Node2D
var score = 0

func _ready():
	$Bird.connect("died", died)
	$Bird.connect("scored", scored) # Connect bird's scored signal to game's scored function
	$Bird.connect("scored", $CandyManager.spawn) # Connect bird's scored signal to candy manager's spawn function
	$CandyManager.spawn()
	update_score()

func update_score():
	$UI/ScoreLabel.text = "Score: %d" % score

func scored():
	score += 1
	$CandyManager.spawn()
	update_score()

func died():
	score = 0
	update_score()
