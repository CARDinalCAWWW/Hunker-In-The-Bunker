extends CharacterBody2D

@onready var hitbox_area: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var attack_sprite: Sprite2D = $AttackArea/SlashSprite

@export var move_speed = 16.0
@export var ATTACK_COOLDOWN = 0.5

@export var attack_distance = 20.0

@export var player_health = 5
@export var IFRAME_TIME = 4.0

var can_attack := true
var is_invincible := false
var attack_area_origin := Vector2.ZERO

func _ready():
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	hitbox_area.body_entered.connect(_on_hitbox_body_entered)
	attack_area_origin = attack_area.position
	
	attack_sprite.visible = false

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		velocity = direction * move_speed
		velocity = cartesian_to_isometric(velocity)
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _process(delta):
	if Input.is_action_just_pressed("attack") and can_attack:
		perform_attack()

func cartesian_to_isometric(cartesian):
	var screen_pos = Vector2()
	screen_pos.x = cartesian.x - cartesian.y
	screen_pos.y = (cartesian.x + cartesian.y) / 2
	return screen_pos 

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemy"):
		take_damage()
		if player_health == 1:
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
	
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
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
	print("IM DED")
	queue_free()
