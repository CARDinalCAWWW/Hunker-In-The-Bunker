extends AnimatedSprite2D

func _ready():
	await owner.ready
	if not is_instance_valid(self):
		return
	if sprite_frames == null:
		return
	if sprite_frames.has_animation("Walk"):
		play("Walk")

func _notification(what):
	if what == NOTIFICATION_EXIT_TREE or what == NOTIFICATION_PREDELETE:
		if sprite_frames != null:
			stop()

func _physics_process(_delta):
	if not is_inside_tree() or not is_instance_valid(self):
		return
	var velocity = get_parent().velocity
	if velocity.x > 0:
		flip_h = false
	elif velocity.x < 0:
		flip_h = true
