extends Node2D

func _on_classic_button_pressed():
	get_tree().change_scene_to_file("res://classic/game_classic.tscn")

func _on_stacky_button_pressed():
	get_tree().change_scene_to_file("res://stacky/game_stacky.tscn")

func _on_spikey_button_pressed() -> void:
	get_tree().change_scene_to_file("res://spikey/game_spikey.tscn")
