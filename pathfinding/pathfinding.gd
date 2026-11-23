class_name Pathfinding
extends Node3D

## Pathfinding contains the methods and data for pathfinding through
## a grid created by a Map node. It does not actually move anything.

signal _update_debug_menu(
	real_position_a: String, grid_position_a: String,
	real_position_b: String, grid_position_b: String,
	real_path: String, grid_path: String
	)

# Contains the grid information we need
@export var map: Map = null

enum Algorithm {BREADTH_FIRST_SEARCH, DEPTH_FIRST_SEARCH, DIJKSTRA, A_STAR}

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


func _ready() -> void:
	# Make creep and waypoint conform
	@warning_ignore("narrowing_conversion")
	if Vector2i(creep.get_position().x, creep.get_position().y) != map.pos_to_tile(creep.get_position()):
		push_warning("Creep position does not conform to grid... Moving!")
		creep.set_position(map.tile_to_world_position(map.pos_to_tile(creep.get_position())))
	@warning_ignore("narrowing_conversion")
	if Vector2i(waypoint.get_position().x, waypoint.get_position().y) != map.pos_to_tile(waypoint.get_position()):
		push_warning("Waypoint position does not conform to grid... Moving!")
		waypoint.set_position(map.tile_to_world_position(map.pos_to_tile(waypoint.get_position())))
	
	if map == null:
		push_error("Please supply a map in the @export map variable!")
	if creep == null:
		push_error("Please supply a creep so we can send it to a destination.")
	if waypoint == null:
		push_error("Please supply a waypoint so it can be a destination.")


## Takes in 2 positions and finds a path between them using the requested algorithm.
## Returned paths are NOT guarenteed to be valid and may be empty.
func find_path(unit_position: Vector3, destination_position: Vector3, algorithm: Algorithm) -> Array[Vector2i]:
	_update_debug_menu.emit(str(unit_position), "", str(destination_position))
	
	var path: Array[Vector2i] = []
	
	match algorithm:
		Algorithm.BREADTH_FIRST_SEARCH:
			path = breadth_first_search(unit_position, destination_position)
		Algorithm.DEPTH_FIRST_SEARCH:
			path = depth_first_search(unit_position, destination_position)
		Algorithm.DIJKSTRA:
			pass
		Algorithm.A_STAR:
			pass
	
	if path.is_empty():
		push_warning("Path is empty. Be careful if you expected data!")
	
	var real_path: Array[Vector3] = []
	for tile_position: Vector2i in path:
		real_path.push_back(map.tile_to_world_position(tile_position))
	
	_update_debug_menu.emit("", "", "", "", str(real_path), str(path))
	
	return path


## @deprecated: Map was given a class name in commit [url=https://github.com/rubedo-red/AI-ICA/commit/31d54d6a6ca002f17dd90a4119c7c4533efbd4c9#diff-0b5ca7d95fad14bec772b88930902f37eb1590a31cd69872963220be008e94f6]31d54d6[/url].
## Turns the evil typeless array returned by map's pos_to_tile() method into a nice Vector2i!
func _pos_to_tile_array_to_vector(evil_array: Array) -> Vector2i:
	# This cast is always going to be unsafe as the Array has no specific type :/ Ignore it !
	@warning_ignore("unsafe_call_argument")
	return Vector2i(evil_array[0], evil_array[1])


func breadth_first_search(start_position: Vector3, end_position: Vector3) -> Array[Vector2i]:
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
					#return true 
					return []
		distance += 1
	
	#return false
	return []


## Calls a recursive _dfs_search_next method. Has a boolean array that has an entry for each cell the map has.
func depth_first_search(start_position: Vector3, end_position: Vector3) -> Array[Vector2i]:
	var starting_tile: Vector2i = map.pos_to_tile(start_position)
	var end_tile: Vector2i = map.pos_to_tile(end_position)
	var path: Array[Vector2i] = []
	
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
	
	if _dfs_search_next(starting_tile, end_tile, searched_cells, path):
		print_debug("Found end_tile!")
	else:
		print_debug("Could not find end_tile :(")
	
	return path

## Private recursive method. Returns true if the end_tile was found, otherwise returns false.
func _dfs_search_next(
	current_tile: Vector2i, end_tile: Vector2i, searched_tiles: Array[bool], path: Array[Vector2i]
	) -> bool:
	if _debug_print_current_tile:
		print_debug("Searching tile ", current_tile)
	
	if current_tile == end_tile:
		path.push_front(current_tile)
		return true
	
	searched_tiles[current_tile.y * map.width + current_tile.x] = true
	
	# We CAN progress if we are NOT going out of map bounds
	# or if we are NOT going onto a tile we've already searched
	# TODO: There are duplicate push_fronts(current_tile)
	if not (current_tile.x + 1 >= map.width or searched_tiles[current_tile.y * map.width + current_tile.x + 1] == true):
		#creep.set_position(Vector3(map.))
		if _dfs_search_next(Vector2i(current_tile.x + 1, current_tile.y), end_tile, searched_tiles, path):
			path.push_front(current_tile)
			return true
	if not (current_tile.y - 1 < 0 or searched_tiles[(current_tile.y - 1) * map.width + current_tile.x] == true):
		if _dfs_search_next(Vector2i(current_tile.x, current_tile.y - 1), end_tile, searched_tiles, path):
			path.push_front(current_tile)
			return true
	if not (current_tile.y + 1 >= map.height or searched_tiles[(current_tile.y + 1) * map.width + current_tile.x] == true):
		if _dfs_search_next(Vector2i(current_tile.x, current_tile.y + 1), end_tile, searched_tiles, path):
			path.push_front(current_tile)
			return true
	if not (current_tile.x - 1 < 0 or searched_tiles[current_tile.y * map.width + current_tile.x - 1] == true):
		if _dfs_search_next(Vector2i(current_tile.x - 1, current_tile.y), end_tile, searched_tiles, path):
			path.push_front(current_tile)
			return true
	
	# If we are completly stuck and have no other tiles left to go
	push_warning("Got stuck!")
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
