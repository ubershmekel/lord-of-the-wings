extends Node


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
