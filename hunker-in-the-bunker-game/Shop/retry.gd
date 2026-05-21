# retry.gd
extends Button

func _on_pressed() -> void:
	ScoreManager.current_level = 1
	get_tree().call_deferred("change_scene_to_file", "res://PlayArea/play_area.tscn")
