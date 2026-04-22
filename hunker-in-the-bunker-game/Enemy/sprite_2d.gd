extends AnimatedSprite2D

func _ready():
	play("Walk")

func _physics_process(_delta):
	var velocity = get_parent().velocity 
	
	if velocity.x > 0:
		flip_h = false  
	elif velocity.x < 0:
		flip_h = true 
