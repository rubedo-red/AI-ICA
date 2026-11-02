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
	var flip_flop: bool = false
	for i: int in grid_size.y:
		for j: int in grid_size.x:
			var cell: Sprite3D = Sprite3D.new()
			
			if !flip_flop:
				cell.set_texture(cell_texture_2)
			else:
				cell.set_texture(cell_texture_1)
			cell.set_pixel_size(1.0)
			
			cell.rotate_x(deg_to_rad(90))
			
			cell.position.x = j * -cell_size
			cell.position.z = i * -cell_size
			
			cells.append(cell)
			add_child(cell)
			
			flip_flop = !flip_flop
		
		flip_flop = !flip_flop
	
	var tmp_cells: Array[Sprite3D] = get_cells_in_column(2)
	print(tmp_cells.size())
	#for i: int in tmp_cells.size():
		#print(tmp_cells[i].get_texture())
	
	pass # Replace with function body.


## Creates a new grid of the size.
## Returns false if the new grid could not be created.
func create_grid(new_grid_size: Vector2i) -> bool:
	
	
	return false


func get_cells_in_column(column: int) -> Array[Sprite3D]:
	var cell_array: Array[Sprite3D] = []
	
	if column < 0 or column >= grid_size.x:
		push_error("Requested column is out of grid bounds :(")
		return cell_array
	
	var array_offset: int = column
	for i: int in grid_size.y:
		# TODO: Below gives out of bounds error from line 41
		cell_array.append(cells[i + array_offset])
		# Skip to the first
		array_offset += grid_size.x
	
	return cell_array


func get_cells_in_row(row: int) -> Array[Sprite3D]:
	var cell_array: Array[Sprite3D] = []
	
	if row < 0 or row >= grid_size.y:
		push_error("Requested row is out of grid bounds :(")
		return cell_array
	
	var array_offset: int = grid_size.x * row
	for i: int in grid_size.x:
		cell_array.append(cells[i + array_offset])
	
	return cell_array
