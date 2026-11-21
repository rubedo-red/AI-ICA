class_name Minimap
extends Control

@export var map: Map

@onready var cells : GridContainer = $AspectRatioContainer/cells_grid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cells.add_theme_constant_override("h_separation", 4)
	cells.add_theme_constant_override("v_separation", 4)
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
		var cell_rect : ColorRect = ColorRect.new()
		cell_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var cell : Map.terrain_types = map.cells[i]
		cell_rect.color = Color(1.0, 0.0, 0.0, 1.0)
		match cell:
			Map.terrain_types.land:
				cell_rect.color = Color(0.0, 0.8, 0.0, 1.0)
			Map.terrain_types.water:
				cell_rect.color = Color(0.299, 0.57, 1.0, 1.0)
			Map.terrain_types.mountain:
				cell_rect.color = Color(0.523, 0.606, 0.74, 1.0) 
		cells.add_child(cell_rect)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
