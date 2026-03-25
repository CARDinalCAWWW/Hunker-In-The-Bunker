extends CharacterBody2D

@export var speed = 100
@onready var navigation_agent = $NavigationAgent2D
@onready var player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if player == null:
		return
	
	navigation_agent.target_position = player.global_position
	
	if navigation_agent.is_navigation_finished():
		return
	
	var next_path_position = navigation_agent.get_next_path_position()
	var new_velocity = global_position.direction_to(next_path_position) * speed
	velocity = new_velocity
	move_and_slide()
