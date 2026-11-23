extends HBoxContainer

## Pathfind Debug Menu provides buttons to force pathfinding functions and 
## information about current pathfinding variables

@export var pathfinding: Pathfinding = null
@export var character: Node3D = null
@export var end_point: Node3D = null
@export var camera: CameraPlayer3D = null
@export_category("Print Statements")
@export var _debug_print_start_tile: bool = false
@export var _debug_print_end_tile: bool = false

# Pathfinding settings
@onready var algorithm_selector: OptionButton = $PathfindingButtons/AlgorithmSelectionContainer/OptionButton

# Pathfinding Information
@onready var creep_position_label: Label = $PathfindingInformationContainer/CreepPositionLabel
@onready var creep_position_on_grid_label: Label = $PathfindingInformationContainer/CreepPositionOnGridLabel
@onready var waypoint_position_label: Label = $PathfindingInformationContainer/WaypointPositionLabel
@onready var waypoint_position_on_grid_label: Label = $PathfindingInformationContainer/WaypointPositionOnGridLabel
@onready var path_label: Label = $PathfindingInformationContainer/PathLabelContainer/PathLabel
@onready var path_on_grid_label: Label = $PathfindingInformationContainer/PathOnGridLabelContainer/PathOnGridLabel

var _valid: bool = false


func _ready() -> void:
	# Ready checks
	if pathfinding == null:
		push_error("Provide a pathfinding node in order to use this debug menu.")
		return
	if character == null:
		push_error("Provide a character node in order to use this debug menu.")
		return
	if end_point == null:
		push_error("Provide an end_point node in order to use this debug menu.")
		return
	if camera == null:
		push_error("Provide a camera in order to use this debug menu.")
	
	pathfinding._update_debug_menu.connect(_update_debug_menu)
	
	_valid = true


func _on_start_algorithm_button_up() -> void:
	# TODO: Warning because get_node() returns a node type, but we want an OptionButton type
	match algorithm_selector.get_selected():
		0:
			pathfinding.creep.pathfinding_aware.path = pathfinding.find_path(
				character.get_position(),
				end_point.get_position(),
				pathfinding.Algorithm.BREADTH_FIRST_SEARCH
			)
		1:
			pathfinding.creep.pathfinding_aware.path = pathfinding.find_path(
				character.get_position(),
				end_point.get_position(),
				pathfinding.Algorithm.DEPTH_FIRST_SEARCH
			)
		2:
			pass
		3:
			pass
		_:
			push_error("Invalid index")


# TODO: We need to ensure we don't run this when the creep isn't [PathfindingAware]
func _on_creep_go_to_next_position_button_up() -> void:
	pathfinding.creep.pathfinding_aware.current_path_index += 1
	
	if pathfinding.creep.pathfinding_aware.path.is_empty():
		push_error("Path is empty. Please run an algorithm!")
		return
	
	if not pathfinding.creep.pathfinding_aware.current_path_index < pathfinding.creep.pathfinding_aware.path.size() - 1:
		push_warning("At the end of the path!")
		return
	
	pathfinding.creep.set_position(pathfinding.map.tile_to_world_position(pathfinding.creep.pathfinding_aware.path[pathfinding.creep.pathfinding_aware.current_path_index]))
	print_debug(pathfinding.creep.pathfinding_aware.current_path_index)
	print_debug(pathfinding.creep.pathfinding_aware.path[pathfinding.creep.pathfinding_aware.current_path_index])


func _on_reset_creep_position_button_up() -> void:
	pathfinding.creep.set_position(Vector3.ZERO)


func _on_teleport_camera_to_creep_button_up() -> void:
	camera.set_position(Vector3(
	pathfinding.creep.get_position().x, 
	pathfinding.creep.get_position().y + pathfinding.map.cell_size, 
	pathfinding.creep.get_position().z
	))
	
	print_debug("Camera was teleported to: ", camera.get_position())
	print_debug("which is tile ", pathfinding.map.pos_to_tile(camera.get_position()), " on the grid!")


func _on_teleport_camera_to_waypoint_button_up() -> void:
	camera.set_position(Vector3(
		pathfinding.waypoint.get_position().x, 
		pathfinding.waypoint.get_position().y + pathfinding.map.cell_size, 
		pathfinding.waypoint.get_position().z
		))
	
	print_debug("Camera was teleported to: ", camera.get_position())
	print_debug("Which is tile ", pathfinding.map.pos_to_tile(camera.get_position()), " on the grid!")


func _on_teleport_creep_to_waypoint_button_up() -> void:
	pathfinding.creep.set_position(pathfinding.waypoint.get_position())
	
	print_debug("Creep is now at ", pathfinding.creep.get_position())
	print_debug("Waypoint is at ", pathfinding.waypoint.get_position())


#region Creep Grid Movement
func _on_cgm_left_button_up() -> void:
	creep_grid_movement(Vector2i(-1, 0))


func _on_cgm_up_button_up() -> void:
	creep_grid_movement(Vector2i(0, -1))


func _on_cgm_down_button_up() -> void:
	creep_grid_movement(Vector2i(0, 1))


func _on_cgm_right_button_up() -> void:
	creep_grid_movement(Vector2i(1, 0))

func creep_grid_movement(direction: Vector2i) -> void:
	if not _valid:
		return
	
	direction = direction.clamp(-Vector2.ONE, Vector2.ONE)
	
	# Bounds check
	var current_tile: Vector2i = pathfinding.map.pos_to_tile(pathfinding.creep.get_position())
	
	if current_tile.x + direction.x >= pathfinding.map.width or current_tile.x - direction.x < 0 or \
	current_tile.y + direction.y >= pathfinding.map.height or current_tile.y - direction.y < 0:
		push_warning("This would move us out of map bounds. Not moving.")
		return
	
	pathfinding.creep.set_position(pathfinding.map.tile_to_world_position(current_tile + direction))
#endregion


# If the given string is empty then don't update that particular value
func _update_debug_menu(
	real_unit_position: String = "", real_destination_position: String = "", 
	grid_unit_position: String = "", grid_destination_position: String = "",
	real_path: String = "", grid_path: String = ""
	) -> void:
	if real_unit_position != "":
		creep_position_label.set_text("Creep Position: " + str(real_unit_position))
	if grid_unit_position != "":
		creep_position_on_grid_label.set_text("Creep Positionon on Grid: " + str(grid_unit_position))
	if real_destination_position != "":
		waypoint_position_label.set_text("Destination Position: " + str(real_destination_position))
	if grid_destination_position != "":
		waypoint_position_on_grid_label.set_text("Destination Position on Grid: " + str(grid_destination_position))
	if real_path != "":
		path_label.set_text("Path: " + str(real_path))
	if real_path != "":
		path_label.set_text("Path on Grid: " + str(grid_path))
