extends Resource
class_name ItemData

@export var item_name: String

@export var icon: Texture2D

# Can this item be spawned into the world?
@export var placeable: bool = false

# Scene that gets spawned
@export var world_scene: PackedScene

# item_data.gd
@export var is_speed_upgrade: bool = false
