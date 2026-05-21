extends ProgressBar

var parent
var max_value_amount
var min_value_amount

func _ready():
	parent = get_tree().get_first_node_in_group("player")
	max_value_amount = parent.ATTACK_COOLDOWN
	min_value_amount = 0  # dead, not starting health

	self.max_value = max_value_amount
	self.min_value = min_value_amount

func _process(_delta: float) -> void:
	if not is_instance_valid(parent):
		self.visible = false
		return

	self.value = parent.ATTACK_COOLDOWN - parent.attack_cooldown_timer
	self.visible = true  # always show while player is alive
