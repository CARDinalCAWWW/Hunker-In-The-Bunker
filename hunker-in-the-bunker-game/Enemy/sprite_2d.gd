extends AnimatedSprite2D

func _ready():
	await owner.ready
	if sprite_frames == null:
		return
	if sprite_frames.has_animation("Walk"):
		play("Walk")

func _physics_process(_delta):
	if not is_inside_tree():
		return
	var velocity = get_parent().velocity
	if velocity.x > 0:
		flip_h = false
	elif velocity.x < 0:
		flip_h = true
