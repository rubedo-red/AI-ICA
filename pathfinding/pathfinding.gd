extends Node3D


# TODO: Remove all the warning ignores once we ... discuss ... how map.gd was written


# TODO: Map has no static type in this early version!!! Fixed in later version!!
# I used Node3D otherwise Godot thinks I want to export something that only accepts NULL
# I also ignored unsafe_method_access warnings BECAUSE WE NEED A TYPE FOR THE MAP !!!!!!!!!!!!!!!!!
@export var map: Map = null
## This unit will try and find a waypoint.
@export var creep: CharacterBody3D = null
## What the unit will try and find.
@export var waypoint: PathfindingWaypoint = null
@export_category("Debug")
@export var _debug_print_start_tile: bool = false
@export var _debug_print_end_tile: bool = false
@export_subgroup("Depth-first Search")
# ATTENTION: This will cause an output buffer overflow in Godot's output log.
# Please look at the output terminal instead!
# (You can find this in the directory in which you installed Godot)
@export var _debug_print_current_tile: bool = false
@export_subgroup("Breadth-first Search")

# TODO: Lazy ! Scope this properly!
var valid_path: Array[Vector2i]

## @experimental: Yep
var _debug_current_path_index: int = 0
## @experimental: For debug menu
@onready var auto_move_creep: CheckBox = $HBoxContainer2/VBoxContainer/CheckBox

func _ready() -> void:
	@warning_ignore("narrowing_conversion")
	if Vector2i(creep.get_position().x, creep.get_position().y) != map.pos_to_tile(creep.get_position()):
		push_warning("Creep position does not conform to grid... Moving!")
		creep.set_position(map.tile_to_world_position(map.pos_to_tile(creep.get_position())))
	@warning_ignore("narrowing_conversion")
	if Vector2i(waypoint.get_position().x, waypoint.get_position().y) != map.pos_to_tile(waypoint.get_position()):
		push_warning("Waypoint position does not conform to grid... Moving!")
		waypoint.set_position(map.tile_to_world_position(map.pos_to_tile(waypoint.get_position())))


func _on_button_button_up() -> void:
	if map == null:
		push_error("Please supply a map in the @export map variable!")
		return
	if creep == null:
		push_error("Please supply a creep so we can send it to a destination.")
		return
	if waypoint == null:
		push_error("Please supply a waypoint so it can be a destination.")
		return
	
	$HBoxContainer2/VBoxContainer2/CreepPositionLabel.set_text("Creep Position: " + str(creep.get_position()))
	$HBoxContainer2/VBoxContainer2/WaypointPositionLabel.set_text("Destination Position: " + str(waypoint.get_position()))
	
	# Clear old saved path (potentially computed by other algorithms)
	valid_path.clear()
	$HBoxContainer2/VBoxContainer2/ScrollContainer/PathLabel.set_text("Valid Path: NOT COMPUTED")
	_debug_current_path_index = 0
	
	# TODO: Warning because get_node() returns a node type, but we want an OptionButton type
	match $HBoxContainer2/VBoxContainer/HBoxContainer/OptionButton.get_selected():
		0:
			depth_first_search()
		1:
			if breadth_first_search():
				print_debug("Creep found the waypoint :)))))")
			else:
				print_debug("Creep could not find the waypoint :(((((")
		2:
			pass
		3:
			pass
		_:
			push_error("Invalid index")
	
	if valid_path.is_empty():
		push_warning("valid_path is empty.. Something went wrong :(")
		return
	
	$HBoxContainer2/VBoxContainer2/ScrollContainer/PathLabel.set_text("Valid Path: " + str(valid_path))


## @deprecated: Map was given a class name in commit [url=https://github.com/rubedo-red/AI-ICA/commit/31d54d6a6ca002f17dd90a4119c7c4533efbd4c9#diff-0b5ca7d95fad14bec772b88930902f37eb1590a31cd69872963220be008e94f6]31d54d6[/url].
## Turns the evil typeless array returned by map's pos_to_tile() method into a nice Vector2i!
func _pos_to_tile_array_to_vector(evil_array: Array) -> Vector2i:
	# This cast is always going to be unsafe as the Array has no specific type :/ Ignore it !
	@warning_ignore("unsafe_call_argument")
	return Vector2i(evil_array[0], evil_array[1])


## Calls a recursive _dfs_search_next method. Has a boolean array that has an entry for each cell the map has.
func depth_first_search() -> void:
	var starting_tile: Vector2i = map.pos_to_tile(creep.get_position())
	var end_tile: Vector2i = map.pos_to_tile(waypoint.get_position())
	
	if _debug_print_start_tile:
		print_debug("Starting tile: ", starting_tile)
		print_debug("Actual position: ", creep.get_position())
	if _debug_print_end_tile:
		print_debug("End tile: ", end_tile)
		print_debug("Actual position: ", waypoint.get_position())
	
	# Array of cells we've searched. True means they've been searched.
	var searched_cells: Array[bool] = []
	for cell: int in map.cells:
		searched_cells.append(false)
	
	if _dfs_search_next(starting_tile, end_tile, searched_cells):
		print_debug("Found end_tile!")
	else:
		print_debug("Could not find end_tile :(")

## Private recursive method. Returns true if the end_tile was found, otherwise returns false.
func _dfs_search_next(current_tile: Vector2i, end_tile: Vector2i, searched_tiles: Array[bool]) -> bool:
	if _debug_print_current_tile:
		print_debug("Searching tile ", current_tile)
	
	if auto_move_creep.is_pressed():
		creep.set_position(map.tile_to_world_position(current_tile))
		print_debug("Creep moved to tile: ", current_tile)
		print_debug("Creep should now be at ", map.tile_to_world_position(current_tile))
		print_debug("Is actually at ", creep.get_position())
	
	if current_tile == end_tile:
		valid_path.push_front(current_tile)
		return true
	
	searched_tiles[current_tile.y * map.width + current_tile.x] = true
	
	# We CAN progress if we are NOT going out of map bounds
	# or if we are NOT going onto a tile we've already searched
	# TODO: There are duplicate push_fronts(current_tile)
	if not (current_tile.x + 1 >= map.width or searched_tiles[current_tile.y * map.width + current_tile.x + 1] == true):
		#creep.set_position(Vector3(map.))
		if _dfs_search_next(Vector2i(current_tile.x + 1, current_tile.y), end_tile, searched_tiles):
			valid_path.push_front(current_tile)
			return true
	if not (current_tile.y - 1 < 0 or searched_tiles[(current_tile.y - 1) * map.width + current_tile.x] == true):
		if _dfs_search_next(Vector2i(current_tile.x, current_tile.y - 1), end_tile, searched_tiles):
			valid_path.push_front(current_tile)
			return true
	if not (current_tile.y + 1 >= map.height or searched_tiles[(current_tile.y + 1) * map.width + current_tile.x] == true):
		if _dfs_search_next(Vector2i(current_tile.x, current_tile.y + 1), end_tile, searched_tiles):
			valid_path.push_front(current_tile)
			return true
	if not (current_tile.x - 1 < 0 or searched_tiles[current_tile.y * map.width + current_tile.x - 1] == true):
		if _dfs_search_next(Vector2i(current_tile.x - 1, current_tile.y), end_tile, searched_tiles):
			valid_path.push_front(current_tile)
			return true
	
	# If we are completly stuck and have no other tiles left to go
	push_warning("Got stuck!")
	return false


func breadth_first_search() -> bool:
	var starting_tile: Vector2i = map.pos_to_tile(creep.get_position())
	var end_tile: Vector2i = map.pos_to_tile(waypoint.get_position())
	
	if _debug_print_start_tile:
		print_debug("Creep is starting at: ", starting_tile)
		print_debug("(", creep.get_position(), ")")
	if _debug_print_end_tile:
		print_debug("End waypoint is at: ", end_tile)
		print_debug("(", waypoint.get_position(), ")")
	
	var distance: int = 0
	while distance <= max(abs(end_tile.x - starting_tile.x), abs(end_tile.y - starting_tile.y)):
		# Check ALL tiles within the square boundary defined by distance
		for i: int in range(starting_tile.x - distance, starting_tile.x + distance + 1):
			for j: int in range(starting_tile.y - distance, starting_tile.y + distance + 1):
				if Vector2i(i, j) == end_tile:
					return true 
		distance += 1
	
	return false


func dijkstra() -> void:
	var starting_tile: Vector2i = map.pos_to_tile(creep.get_position())
	var end_tile: Vector2i = map.pos_to_tile(waypoint.get_position())
	
	if _debug_print_start_tile:
		print_debug(starting_tile)
	if _debug_print_end_tile:
		print_debug(end_tile)


func _dijkstra_search_next(current_tile: Vector2i, end_tile: Vector2i, searched_tiles: Array[bool], passed_cost: int) -> bool:
	var current_cost: int = passed_cost
	
	if _debug_print_current_tile:
		print_debug("Searching tile ", current_tile)
	
	if current_tile == end_tile:
		return true
	
	searched_tiles[current_tile.y * map.width + current_tile.x] = true
	
	#var potential_costs: Array[int] = [1, 2]
	
	push_warning("Got stuck!")
	return false


## @experimental: THIS IS A DEBUG METHOD !!! DONT USE !!!
## Teleport the [CameraPlayer3D] (name must not be changed) 1 cell above the creep.
func _on_button_2_button_up() -> void:
	$CameraPlayer3D.set_position(Vector3(
		creep.get_position().x, 
		creep.get_position().y + map.cell_size, 
		creep.get_position().z
		))
	
	print_debug("CameraPlayer3D's was teleported to: ", $CameraPlayer3D.get_position())
	print_debug("which is tile ", map.pos_to_tile($CameraPlayer3D.get_position()), " on the grid!")


## @experimental: THIS IS A DEBUG METHOD !!! DONT USE !!!
## Teleport the [CameraPlayer3D] (name must not be changed) 1 cell above the waypoint.
func _on_button_3_button_up() -> void:
	$CameraPlayer3D.set_position(Vector3(
		waypoint.get_position().x, 
		waypoint.get_position().y + map.cell_size, 
		waypoint.get_position().z
		))
	
	print_debug("CameraPlayer3D's was teleported to: ", $CameraPlayer3D.get_position())
	print_debug("Which is tile ", map.pos_to_tile($CameraPlayer3D.get_position()), " on the grid!")


# Mysterious teleport creep to waypoint function
func _on_button_4_button_up() -> void:
	creep.set_position(waypoint.get_position())
	
	print_debug("Creep is now at ", creep.get_position())
	print_debug("Waypoint is at ", waypoint.get_position())


func _on_button_5_button_up() -> void:
	_debug_current_path_index += 1
	
	if valid_path.is_empty():
		push_error("Path is empty. Please run an algorithm!")
		return
	
	if not _debug_current_path_index < valid_path.size() - 1:
		push_warning("At the end of the path!")
		return
	
	creep.set_position(map.tile_to_world_position(valid_path[_debug_current_path_index]))
	print_debug(_debug_current_path_index)
	print_debug(valid_path[_debug_current_path_index])


func _on_button_6_button_up() -> void:
	creep.set_position(Vector3.ZERO)


#region Creep Grid Movement
func _on_cgm_left_button_up() -> void:
	creep_grid_movement(Vector2i(-1, 0))


func _on_cgm_up_button_up() -> void:
	creep_grid_movement(Vector2i(0, -1))


func _on_cgm_down_button_up() -> void:
	creep_grid_movement(Vector2i(0, 1))


func _on_cgm_right_button_up() -> void:
	creep_grid_movement(Vector2i(1, 0))

func creep_grid_movement(direction: Vector2i):
	direction = direction.clamp(-Vector2.ONE, Vector2.ONE)
	
	# Bounds check
	var current_tile: Vector2i = map.pos_to_tile(creep.get_position())
	
	if current_tile.x + direction.x >= map.width or current_tile.x - direction.x < 0 or \
	current_tile.y + direction.y >= map.height or current_tile.y - direction.y < 0:
		push_warning("This would move us out of map bounds. Not moving.")
		return
	
	creep.set_position(map.tile_to_world_position(current_tile + direction))

#endregion
