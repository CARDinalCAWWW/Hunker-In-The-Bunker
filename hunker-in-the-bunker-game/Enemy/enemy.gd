extends CharacterBody2D

var speed
@export var speed_inc = 3
@export var current_max_speed = 20
@export var top_speed = 40

@onready var navigation_agent = $NavigationAgent2D
@onready var player = get_tree().get_first_node_in_group("player")

@export var DEATH_COOLDOWN = 2.0
@export var enemy_health = 2


var got_hit := false
const ENEMY_SCENE = preload("res://Enemy/enemy.tscn")

func _ready():
	speed = randf_range(10,current_max_speed)
	var health_bar = get_node_or_null("EnemyHealth")
	if health_bar:
		health_bar.setup(self)
	else:
		print("EnemyHealth no found!!")

func _process(delta):
	if enemy_health <= 0:
		die()

func _physics_process(_delta):
	player = get_tree().get_first_node_in_group("player")
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
	enemy_health -= 1
	
	$Sprite2D.play("Stun")
	
	if current_max_speed < top_speed:
		current_max_speed += speed_inc
	
	await get_tree().create_timer(DEATH_COOLDOWN).timeout
	
	$Sprite2D.play("Get Up")
	await $Sprite2D.animation_finished
	
	var new_enemy = ENEMY_SCENE.instantiate()
	var x_offset = randf_range(-7, -4) if randi() % 2 == 0 else randf_range(4,7)
	var y_offset = randf_range(-7, -4) if randi() % 2 == 0 else randf_range(4,7)
	new_enemy.global_position = global_position + Vector2(x_offset, y_offset)
	
	# New enemy inherits speed upgrades
	new_enemy.current_max_speed = current_max_speed
	new_enemy.top_speed = top_speed
	new_enemy.speed_inc = speed_inc
	
	get_parent().add_child(new_enemy)
	$Sprite2D.play("NewZombie")
	await $Sprite2D.animation_finished
	$Sprite2D.play("Walk")
	
	got_hit = false

func die():
	var score_node = get_tree().get_first_node_in_group("score")
	if score_node:
		print("Score node found: ", score_node )
		ScoreManager.add_score()
	else:
		print("Score_node not found")
	queue_free()
