extends Area2D

@export var speed: float = 500.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	# Move the bullet forward based on its rotation
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	# Damage logic goes here
	if body.has_method("take_damage"):
		body.take_damage()
	queue_free() # Destroy bullet on impact
