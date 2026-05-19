extends Control

@export var item: ItemData
@export var cost: int = 5

@onready var icon: TextureRect = $Icon
@onready var cost_label: Label = $CostLabel
@onready var buy_button: Button = $BuyButton

func _ready() -> void:
	if item:
		icon.texture = item.icon
	cost_label.text = "%d pts" % cost
	ScoreManager.score_changed.connect(_on_score_changed)
	_on_score_changed(ScoreManager.score)
	print("Item: ", item)
	print("Cost: ", cost)
	print("Button disabled: ", buy_button.disabled)
	print("ScoreManager score: ", ScoreManager.score)

func _on_score_changed(new_score: int) -> void:
	buy_button.disabled = new_score < cost

func _on_buy_button_pressed() -> void:
	print("Button pressed!")
	print("Can afford: ", ScoreManager.score >= cost)
	if ScoreManager.buy_item(item, cost):
		print("Bought!")
		var slots = get_tree().get_nodes_in_group("hotbar_slots")
		print("Slots found: ", slots.size())
		for slot in slots:
			if slot.item == item:
				slot.add_item(item)
				return
		for slot in slots:
			if slot.item == null:
				slot.add_item(item)
				return
		ScoreManager.add_score(cost)
		print("Hotbar full, refunded!")
