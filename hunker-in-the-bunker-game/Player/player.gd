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


var dragged_item: ItemData
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
	
	var slots = get_tree().get_nodes_in_group("hotbar_slots")
	var slot_index = 0
	for item in ScoreManager.purchased_items:
		if slot_index >= slots.size():
			break
			slots[slot_index].item = item
			slots[slot_index].quantity = ScoreManager.purchased_items[item]
			slots[slot_index].update_visual()
			slot_index += 1

func _physics_process(_delta: float) -> void:
	var map_pos = tile_map.local_to_map(tile_map.to_local(global_position))
	var tile_data = tile_map.get_cell_tile_data(map_pos)
	var current_modifier = 1.0
	if tile_data and not ScoreManager.has_speed_upgrade:
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

var is_dead := false

func _on_hitbox_body_entered(body):
	if is_dead:
		return
	if body.is_in_group("enemy"):
		take_damage()
		if player_health <= 0:
			die()

func _on_attack_area_body_entered(body):
	if body.is_in_group("enemy"):
		body.stun() # Play stun func from bodies in area
	else:
		return

func perform_attack():
	if is_dead:
		return
	can_attack = false
	attack_shape.disabled = false
	attack_sprite.visible = true
	
	var mouse_pos = get_local_mouse_position()
	var attack_dir = mouse_pos.normalized()
	var attack_target = attack_area_origin + attack_dir * attack_distance
	attack_sprite.rotation = attack_dir.angle()
	attack_area.position = attack_target
	
	await get_tree().create_timer(0.15).timeout
	
	if is_dead:  # check again after await in case player died during attack window
		return
		
	attack_shape.disabled = true
	attack_sprite.visible = false
	attack_area.position = attack_area_origin
	
	attack_cooldown_timer = ATTACK_COOLDOWN
	while attack_cooldown_timer > 0.0:
		if not is_inside_tree():
			return
		await get_tree().process_frame
		if is_dead:
			return
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
	
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:

			var item = null

			if get_tree().root.has_meta("dragged_item"):
				item = get_tree().root.get_meta("dragged_item")

			if item and item.placeable:
				spawn_item(item)

			if get_tree().root.has_meta("dragged_item"):
				get_tree().root.remove_meta("dragged_item")
				
func spawn_item(item_data: ItemData) -> void:
	if item_data.world_scene == null:
		return
	var instance = item_data.world_scene.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = get_global_mouse_position()
	
	# find the slot holding this item and decrease quantity
	var slots = get_tree().get_nodes_in_group("hotbar_slots")
	for slot in slots:
		if slot.item == item_data:
			slot.use_item()
			break
	
func die():
	if is_dead:
		return
	is_dead = true
	death_text.visible = true
	print("IM DED")
	call_deferred("_change_scene")

func _change_scene():
	get_tree().change_scene_to_file("res://Shop/shop_scene.tscn")
