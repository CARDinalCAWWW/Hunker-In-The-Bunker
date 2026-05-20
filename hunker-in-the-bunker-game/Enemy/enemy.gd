extends CharacterBody2D

var speed
@export var speed_inc = 3
@export var current_max_speed = 20
@export var top_speed = 40

@onready var navigation_agent = $NavigationAgent2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var grownsfx = $ZombieSound

@export var DEATH_COOLDOWN = 2.0
@export var enemy_health = 2


var got_hit := false
var is_spawning := false
const ENEMY_SCENE = preload("res://Enemy/enemy.tscn")
const LEVEL_FRAMES = {
	1: preload("res://Resources/PlainsZombie.tres"),
	2: preload("res://Resources/CaveZombie.tres"),
}

func _ready():
	speed = randf_range(10, current_max_speed)
	
	var level = ScoreManager.current_level
	if LEVEL_FRAMES.has(level):
		$Sprite2D.sprite_frames = LEVEL_FRAMES[level]
	
	var health_bar = get_node_or_null("EnemyHealth")
	if health_bar:
		health_bar.setup(self)

func _process(delta):
	if enemy_health <= 0:
		die()

func _physics_process(_delta):
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if got_hit or is_spawning:
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
	
	grownsfx.play()
	got_hit = true
	enemy_health -= 1
	
	if $Sprite2D.sprite_frames.has_animation("Stun"):
		$Sprite2D.play("Stun")
	
	if current_max_speed < top_speed:
		current_max_speed += speed_inc
	
	await get_tree().create_timer(DEATH_COOLDOWN).timeout
	
	spawn_new()

func spawn_new():
	var new_enemy = ENEMY_SCENE.instantiate()
	var x_offset = randf_range(-7, -4) if randi() % 2 == 0 else randf_range(4, 7)
	var y_offset = randf_range(-7, -4) if randi() % 2 == 0 else randf_range(4, 7)
	new_enemy.global_position = global_position + Vector2(x_offset, y_offset)
	
	new_enemy.current_max_speed = current_max_speed
	new_enemy.top_speed = top_speed
	new_enemy.speed_inc = speed_inc
	
	# set frames BEFORE add_child
	var level = ScoreManager.current_level
	if LEVEL_FRAMES.has(level):
		new_enemy.get_node("Sprite2D").sprite_frames = LEVEL_FRAMES[level]
	
	get_parent().add_child(new_enemy)
	new_enemy.is_spawning = true  # freeze new enemy

	# play NewZombie on the newly spawned enemy
	var new_sprite = new_enemy.get_node("Sprite2D")
	if new_sprite.sprite_frames.has_animation("NewZombie"):
		new_sprite.play("NewZombie")
		await new_sprite.animation_finished
		new_sprite.play("Walk")

	new_enemy.is_spawning = false  # unfreeze after animation

	# original enemy gets up
	if $Sprite2D.sprite_frames.has_animation("Get Up"):
		$Sprite2D.play("Get Up")
		await $Sprite2D.animation_finished

	if $Sprite2D.sprite_frames.has_animation("Walk"):
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
