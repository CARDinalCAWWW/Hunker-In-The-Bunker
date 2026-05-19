extends TextureRect

@export var item: ItemData
var quantity: int = 0
var quantity_label: Label

func _ready():
	# finds it if it exists, won't crash if it doesn't
	quantity_label = get_node_or_null("QuantityLabel")
	update_visual()

func update_visual():
	if item:
		texture = item.icon
		visible = true
		if quantity_label:
			quantity_label.text = str(quantity) if quantity > 1 else ""
	else:
		texture = null
		visible = false
		if quantity_label:
			quantity_label.text = ""

func add_item(new_item: ItemData) -> bool:
	if item == null:
		item = new_item
		quantity = 1
		update_visual()
		return true
	elif item == new_item:
		quantity += 1
		update_visual()
		return true
	return false
func _get_drag_data(_at_position):
	if item == null:
		return null
	get_tree().root.set_meta("dragged_item", item)
	var preview = TextureRect.new()
	preview.texture = item.icon
	preview.custom_minimum_size = Vector2(48, 48)
	set_drag_preview(preview)
	return {
		"item": item,
		"source": self
	}

func _drop_data(_position, data):
	var source = data["source"]
	var temp_item = item
	var temp_qty = quantity
	item = data["source"].item
	quantity = data["source"].quantity
	source.item = temp_item
	source.quantity = temp_qty
	update_visual()
	source.update_visual()
func use_item() -> void:
	if item == null:
		return
	quantity -= 1
	if ScoreManager.available_items.has(item):
		ScoreManager.available_items[item] -= 1
		if ScoreManager.available_items[item] <= 0:
			ScoreManager.available_items.erase(item)
	if quantity <= 0:
		quantity = 0
		item = null
	update_visual()
