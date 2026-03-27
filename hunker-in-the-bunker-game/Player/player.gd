extends CharacterBody2D

@onready var hitbox: Area2D = $Hitbox
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

@export var move_speed: float = 16.0
@export var ATTACK_COOLDOWN = 0.5
var can_attack := true

func _ready():
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _process(delta):
	if Input.is_action_just_pressed("attack") and can_attack:
		perform_attack()

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemy"):
		die() # Play die func from bodies in area
	else:
		return

func _on_attack_area_body_entered(body):
	if body.is_in_group("enemy"):
		body.stun() # Play die func from bodies in area
	else:
		return

func perform_attack():
	can_attack = false
	attack_shape.disabled = false # Enable area hitbox
	
	await get_tree().create_timer(0.15).timeout # Hitbox active window
	attack_shape.disabled = true # Disable area hitbox
	
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	can_attack = true

func die():
	print("IM DED")
	pass
