extends ProgressBar

var parent

func setup(enemy_node):
	parent = enemy_node
	self.max_value = parent.enemy_health
	self.min_value = 0
	self.value = parent.enemy_health

func _ready():
	pass  # no longer searching the tree

func _process(delta: float) -> void:
	if not is_instance_valid(parent):
		self.visible = false
		return
	
	self.value = parent.enemy_health
	self.visible = true


### 3. Make sure HealthBar is a child of Enemy in the scene
