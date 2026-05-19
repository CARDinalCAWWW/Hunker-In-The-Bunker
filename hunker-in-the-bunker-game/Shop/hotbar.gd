extends Control

func _ready() -> void:
	ScoreManager.reset_available_items()
	if ScoreManager.available_items.is_empty():
		return
	var slots = get_tree().get_nodes_in_group("hotbar_slots")
	var slot_index = 0
	for item in ScoreManager.available_items:
		if slot_index >= slots.size():
			break
		slots[slot_index].item = item
		slots[slot_index].quantity = ScoreManager.available_items[item]
		slots[slot_index].update_visual()
		slot_index += 1
