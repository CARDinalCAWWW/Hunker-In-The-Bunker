# retry.gd  
extends Button

func _on_pressed() -> void:
	# do NOT increment — same level
	get_tree().change_scene_to_file("res://PlayArea/play_area.tscn")
