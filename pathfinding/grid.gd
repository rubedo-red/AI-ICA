class_name PathfindingGrid3D
extends Node3D

## The amount of cells in the grid. Width and height.
@export var grid_size: Vector2i = Vector2.ONE
## How large each cell is.
@export var cell_size: float = 1.0
@export var cell_texture_1: Texture2D = null
@export var cell_texture_1_alt: Texture2D = null
@export var cell_texture_2: Texture2D = null
@export var cell_texture_2_alt: Texture2D = null

var cells: Array[Sprite3D] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var loop_counter_i: int = 0
	for i: int in grid_size.y:
		var loop_counter_j: int = 0
		for j: int in grid_size.x:
			var cell: Sprite3D = Sprite3D.new()
			
			if false:
				cell.set_texture(cell_texture_2)
			else:
				cell.set_texture(cell_texture_1)
			cell.set_pixel_size(1.0)
			
			cell.rotate_x(deg_to_rad(90))
			
			cell.position.x = loop_counter_j * -cell_size
			cell.position.z = loop_counter_i * -cell_size
			
			cells.append(cell)
			add_child(cell)
			
			loop_counter_j += 1
		
		loop_counter_i += 1
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
