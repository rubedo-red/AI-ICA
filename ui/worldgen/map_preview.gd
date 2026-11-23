class_name Minimap
extends Control

@export var map: Map

@onready var cells : GridContainer = $AspectRatioContainer/cells_grid

const tile_scene := preload("res://ui/worldgen/minimap_tile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cells.add_theme_constant_override("h_separation", 0)
	cells.add_theme_constant_override("v_separation", 0)
	for i in 64:
		var cell_rect : ColorRect = ColorRect.new()
		cell_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cell_rect.color = Color(1.0, 0.0, 0.0, 1.0)
	map.map_regenerated.connect(_on_world_regen)

func _on_world_regen() -> void:
	for c in cells.get_children():
		cells.remove_child(c)
		c.queue_free()
	cells.columns = map.width
	for i in map.width*map.height:
		var cell : Map.terrain_types = map.cells[i]
		var tile := tile_scene.instantiate()
		var rect := tile.get_node("color")
		match cell:
			Map.terrain_types.land:
				rect.color = Color(0.0, 0.8, 0.0, 1.0)
			Map.terrain_types.water:
				rect.color = Color(0.299, 0.57, 1.0, 1.0)
			Map.terrain_types.mountain:
				rect.color = Color(0.523, 0.606, 0.74, 1.0) 
		cells.add_child(tile)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
