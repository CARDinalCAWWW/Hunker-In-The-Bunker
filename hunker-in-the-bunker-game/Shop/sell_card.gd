extends Control
class_name SellCard

@export var card_frame: TextureRect
var hovering: bool

func _process(_delta) -> void:
	if is_mouse_over_card():
		hovering = true
		card_frame.scale = Vector2(1.2, 1.2)
	else:
		hovering = false
		card_frame.scale = Vector2(1, 1)

func is_mouse_over_card() -> bool:
	var mouse_pos := get_global_mouse_position()
	var sprite_rect := Rect2(card_frame.global_position, card_frame.texture.get_size())
	return sprite_rect.has_point(mouse_pos)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and hovering:
			queue_free()   # no points, just remove
