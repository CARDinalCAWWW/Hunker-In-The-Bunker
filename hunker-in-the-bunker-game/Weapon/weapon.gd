extends Area2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var overlapping_bodies = get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("enemy"):
			print("Gotcha!")
