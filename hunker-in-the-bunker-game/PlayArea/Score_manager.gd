extends Node

signal score_changed(new_score: int)

var score := 0
var purchased_items: Dictionary = {}   # permanent record of what was bought
var available_items: Dictionary = {}   # resets each level
var has_speed_upgrade := false
var current_level := 1

func add_score(amount: int = 1) -> void:
	score += amount
	emit_signal("score_changed", score)

func spend(amount: int) -> bool:
	if score >= amount:
		score -= amount
		emit_signal("score_changed", score)
		return true
	return false

func buy_item(item: ItemData, cost: int) -> bool:
	if spend(cost):
		if purchased_items.has(item):
			purchased_items[item] += 1
		else:
			purchased_items[item] = 1
		return true
	return false

func reset_available_items() -> void:
	available_items = purchased_items.duplicate()
