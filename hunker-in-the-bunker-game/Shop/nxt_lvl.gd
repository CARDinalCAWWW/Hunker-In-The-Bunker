extends Button

func _on_pressed() -> void:
	ScoreManager.current_level += 1
	get_tree().change_scene_to_file("res://PlayArea/Cave/play_area_cave.tscn")
