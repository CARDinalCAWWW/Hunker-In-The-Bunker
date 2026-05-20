extends Node2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var detection_zone: Area2D = $DetectionZone
var targets: Array[Node2D] = []
var current_target: Node2D = null

func _ready() -> void:
	detection_zone.body_entered.connect(_on_target_entered)
	detection_zone.body_exited.connect(_on_target_exited)


func find_closest_target() -> void:
	targets = targets.filter(func(t): return is_instance_valid(t))
	
	if targets.is_empty():
		current_target = null
		return

	var closest_target = targets[0]
	var min_distance = global_position.distance_to(closest_target.global_position)
	for target in targets:
		var distance = global_position.distance_to(target.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_target = target
	current_target = closest_target

var kill_on_cooldown := false

func _on_target_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not kill_on_cooldown:
		body.stun()
		await get_tree().create_timer(2.0).timeout
		body.enemy_health = 0
		targets.append(body)
		kill_on_cooldown = true
		await get_tree().create_timer(10.0).timeout
		kill_on_cooldown = false

func _on_target_exited(body: Node2D) -> void:
	targets.erase(body)
