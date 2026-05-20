extends Button

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Shop/shop_scene.tscn")
