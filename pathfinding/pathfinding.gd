extends Node3D

@export var grid: PathfindingGrid3D = null 
@export var creep: CharacterBody3D = null
@export var destination: Node3D = null
@export_category("Debug")
@export var print_creep_position: bool = false
@export var print_destination_position: bool = false
@export var print_cell_position: bool = false
@export var print_valid_cell_found: bool = false

var creep_current_cell: Vector2 = Vector2.ZERO
var destination_current_cell: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Determine Creep square
	find_my_cell(creep, grid)
	
	# Determine Destination Square
	find_my_cell(destination, grid)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_up() -> void:
	match $VBoxContainer/HBoxContainer/OptionButton.get_index():
		0:
			pass
		1:
			pass
		2:
			pass
		3:
			pass
		_:
			push_error("Invalid index")


func find_my_cell(input_node: Node3D, grid_to_check: PathfindingGrid3D) -> Vector2i:
	if print_destination_position:
		print_debug("Input node is at ", input_node.position)
	
	var found_cell: bool = false
	for cell in grid_to_check.cells:
		if print_cell_position:
			print_debug("This cell is at ", floor(cell.position))
			
		if floorf(cell.position.x) == floorf(input_node.position.x) and floorf(cell.position.z) == floorf(input_node.position.z):
			if print_valid_cell_found:
				print_debug("Found valid cell at!")
			found_cell = true
	if not found_cell:
		push_warning("Node is not on the grid :(")
	
	return Vector2i.ZERO
