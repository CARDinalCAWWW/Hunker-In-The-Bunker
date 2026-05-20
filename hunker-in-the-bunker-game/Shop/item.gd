extends ResourcePreloader

class_name Item

@export var item_name: String
@export var icon: Texture2D

# If true, dragging spawns into world
@export var placeable: bool = false

# Scene to spawn
@export var world_scene: PackedScene
