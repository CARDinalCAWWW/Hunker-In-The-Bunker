extends CharacterBody2D

@onready var hitbox_area: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var attack_sprite: Sprite2D = $AttackArea/SlashSprite
@onready var tile_map = get_parent().get_node("TileMapBase")

@onready var death_text: Label = $"../HUD/Death"

@export var move_speed = 16.0
@export var ATTACK_COOLDOWN = 0.5

@export var attack_distance = 20.0

@export var player_health = 5
@export var IFRAME_TIME = 4.0

var can_attack := true
var is_invincible := false
var attack_area_origin := Vector2.ZERO
var attack_cooldown_timer = 0.0

func _ready():
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	hitbox_area.body_entered.connect(_on_hitbox_body_entered)
	attack_area_origin = attack_area.position
	
	attack_sprite.visible = false
	death_text.visible = false

func _physics_process(delta: float) -> void:
	var map_pos = tile_map.local_to_map(tile_map.to_local(global_position))
	var tile_data = tile_map.get_cell_tile_data(map_pos)
	var current_modifier = 1.0
	if tile_data:
		current_modifier = tile_data.get_custom_data("speed_mod")
	
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		velocity = direction * move_speed * current_modifier
		
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _process(delta):
	if Input.is_action_just_pressed("attack") and can_attack:
		perform_attack()



func _on_hitbox_body_entered(body):
	if body.is_in_group("enemy"):
		take_damage()
		if player_health == 0:
			die()
		else:
			return
	else:
		return

func _on_attack_area_body_entered(body):
	if body.is_in_group("enemy"):
		body.stun() # Play stun func from bodies in area
	else:
		return

func perform_attack():
	can_attack = false
	attack_shape.disabled = false # Enable area hitbox
	attack_sprite.visible = true
	
	var mouse_pos = get_local_mouse_position()
	var attack_dir = mouse_pos.normalized()
	var attack_target = attack_area_origin + attack_dir * attack_distance
	attack_sprite.rotation = attack_dir.angle()
	
	attack_area.position = attack_target
	
	await get_tree().create_timer(0.15).timeout # Hitbox active window
	attack_shape.disabled = true # Disable area hitbox
	attack_sprite.visible = false
	attack_area.position = attack_area_origin
	
	attack_cooldown_timer = ATTACK_COOLDOWN
	while attack_cooldown_timer > 0.0:
		await get_tree().process_frame
		attack_cooldown_timer -= get_process_delta_time()
	attack_cooldown_timer = 0.0
	
	can_attack = true

func blink():
	var blink_count = int(IFRAME_TIME / 0.5)  # Blink every 0.5s for the duration
	for i in blink_count + 4:
		modulate.a = 0.2  # Nearly invisible
		await get_tree().create_timer(0.1).timeout
		modulate.a = 1.0  # Fully visible
		await get_tree().create_timer(0.1).timeout

func take_damage():
	if is_invincible:
		return
	print("Owch")
	
	player_health -= 1
	is_invincible = true
	blink()
	await get_tree().create_timer(IFRAME_TIME).timeout
	is_invincible = false
	
	# Toggle hitbox to avoid enemy hugging player
	hitbox_shape.disabled = true
	hitbox_shape.disabled = false
	
	modulate.a = 1.0

func die():
	death_text.visible = true
	print("IM DED")
	queue_free()
