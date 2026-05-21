extends AnimatedSprite2D

func _ready():
	await owner.ready
	if not is_instance_valid(self) or not is_inside_tree():
		return
	if sprite_frames == null:
		return
	if sprite_frames.has_animation("Walk"):
		play("Walk")

func _notification(what):
	if what == NOTIFICATION_EXIT_TREE or what == NOTIFICATION_PREDELETE:
		if is_instance_valid(self) and sprite_frames != null:
			stop()
		set_physics_process(false)
		set_process(false)

func _physics_process(_delta):
	if not is_instance_valid(self) or not is_inside_tree():
		return
	if not is_instance_valid(get_parent()):
		return
	var velocity = get_parent().velocity
	if velocity.x > 0:
		flip_h = false
	elif velocity.x < 0:
		flip_h = true
