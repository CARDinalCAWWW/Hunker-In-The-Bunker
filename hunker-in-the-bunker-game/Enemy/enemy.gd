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
var is_dead := false
const ENEMY_SCENE = preload("res://Enemy/enemy.tscn")
const LEVEL_FRAMES = {
	1: preload("res://Resources/PlainsZombie.tres"),
	2: preload("res://Resources/CaveZombie.tres"),
}

func _ready():
	speed = randf_range(10, current_max_speed)
	var level = ScoreManager.current_level
	if LEVEL_FRAMES.has(level):
		$Sprite2D.sprite_frames = LEVEL_FRAMES[level].duplicate()
	var health_bar = get_node_or_null("EnemyHealth")
	if health_bar:
		health_bar.setup(self)

func _process(_delta):
	if enemy_health <= 0 and not is_dead:
		die()

func _physics_process(_delta):
	if is_dead:
		return
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if got_hit or is_spawning:
		return
	navigation_agent.target_position = player.global_position
	if navigation_agent.is_navigation_finished():
		return
	var next_path_position = navigation_agent.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * speed
	move_and_slide()

func stun():
	if got_hit or is_dead:
		return
	grownsfx.play()
	got_hit = true
	enemy_health -= (1 + ScoreManager.damage_upgrade)
	if $Sprite2D.sprite_frames.has_animation("Stun"):
		$Sprite2D.play("Stun")
	if current_max_speed < top_speed:
		current_max_speed += speed_inc
	await get_tree().create_timer(DEATH_COOLDOWN).timeout
	if is_dead or not is_inside_tree():
		return
	if enemy_health <= 0:
		die()
		return
	spawn_new()

func spawn_new():
	if not is_inside_tree() or is_dead:
		return
	var new_enemy = ENEMY_SCENE.instantiate()
	var x_offset = randf_range(-7, -4) if randi() % 2 == 0 else randf_range(4, 7)
	var y_offset = randf_range(-7, -4) if randi() % 2 == 0 else randf_range(4, 7)
	new_enemy.global_position = global_position + Vector2(x_offset, y_offset)
	new_enemy.current_max_speed = current_max_speed
	new_enemy.top_speed = top_speed
	new_enemy.speed_inc = speed_inc
	var level = ScoreManager.current_level
	if LEVEL_FRAMES.has(level):
		new_enemy.get_node("Sprite2D").sprite_frames = LEVEL_FRAMES[level].duplicate()
	get_parent().add_child(new_enemy)
	new_enemy.is_spawning = true
	var new_sprite = new_enemy.get_node("Sprite2D")
	if new_sprite.sprite_frames and new_sprite.sprite_frames.has_animation("NewZombie"):
		new_sprite.play("NewZombie")
		await new_sprite.animation_finished
	if not is_inside_tree() or is_dead:
		# still unfreeze the new enemy even if parent is dead
		if is_instance_valid(new_enemy):
			new_enemy.is_spawning = false
			if new_enemy.get_node("Sprite2D").sprite_frames.has_animation("Walk"):
				new_enemy.get_node("Sprite2D").play("Walk")
		return
	new_enemy.is_spawning = false
	if new_sprite.sprite_frames and new_sprite.sprite_frames.has_animation("Walk"):
		new_sprite.play("Walk")
	if $Sprite2D.sprite_frames.has_animation("Get Up"):
		$Sprite2D.play("Get Up")
		await $Sprite2D.animation_finished
	if not is_inside_tree() or is_dead:
		return
	if $Sprite2D.sprite_frames.has_animation("Walk"):
		$Sprite2D.play("Walk")
	got_hit = false

func die():
	if is_dead:
		return
	is_dead = true
	ScoreManager.add_score()
	if is_instance_valid($Sprite2D):
		$Sprite2D.stop()
	queue_free()

func _notification(what):
	if what == NOTIFICATION_EXIT_TREE or what == NOTIFICATION_PREDELETE:
		is_dead = true
		if is_instance_valid($Sprite2D):
			$Sprite2D.stop()
