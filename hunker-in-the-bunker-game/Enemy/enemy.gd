extends CharacterBody2D

var speed
@export var speed_inc = 3
@export var current_max_speed = 20
@export var top_speed = 40

@onready var navigation_agent = $NavigationAgent2D
@onready var player = get_tree().get_first_node_in_group("player")

@export var DEATH_COOLDOWN = 2

var got_hit := false
const ENEMY_SCENE = preload("res://Enemy/enemy.tscn")

func _ready():
	speed = randf_range(10,current_max_speed)

func _physics_process(_delta):
	if player == null:
		return
	
	if got_hit:
		return
	
	navigation_agent.target_position = player.global_position
	
	if navigation_agent.is_navigation_finished():
		return
	
	var next_path_position = navigation_agent.get_next_path_position()
	var new_velocity = global_position.direction_to(next_path_position) * speed
	velocity = new_velocity
	move_and_slide()

func stun():
	if got_hit:
		return
	got_hit = true
	
	if current_max_speed < top_speed:
		current_max_speed += speed_inc
	
	await get_tree().create_timer(DEATH_COOLDOWN).timeout
	
	var new_enemy = ENEMY_SCENE.instantiate()
	var x_offset = randf_range(-7, -4) if randi() % 2 == 0 else randf_range(4,7)
	var y_offset = randf_range(-7, -4) if randi() % 2 == 0 else randf_range(4,7)
	new_enemy.global_position = global_position + Vector2(x_offset, y_offset)
	
	# New enemy inherits speed upgrades
	new_enemy.current_max_speed = current_max_speed
	new_enemy.top_speed = top_speed
	new_enemy.speed_inc = speed_inc
	
	get_tree().root.get_node("PlayArea/EnemyContainer").add_child(new_enemy)
	
	got_hit = false
