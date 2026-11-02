extends Node3D


# TODO: Remove all the warning ignores once we ... discuss ... how map.gd was written


# TODO: Map has no static type in this early version!!! Fixed in later version!!
# I used Node3D otherwise Godot thinks I want to export something that only accepts NULL
# I also ignored unsafe_method_access warnings BECAUSE WE NEED A TYPE FOR THE MAP !!!!!!!!!!!!!!!!!
@export var map: Node3D = null
## This unit will try and find a waypoint.
@export var creep: CharacterBody3D = null
## What the unit will try and find.
@export var waypoint: PathfindingWaypoint = null
@export_category("Debug")
@export var _debug_print_start_tile: bool = false
@export var _debug_print_end_tile: bool = false
@export_subgroup("Breadth-first Search")


func _on_button_button_up() -> void:
	if map == null:
		push_error("Please supply a map in the @export map variable!")
		return
	if creep == null:
		push_error("Please supply a creep so we can send it to a destination.")
	if waypoint == null:
		push_error("Please supply a waypoint so it can be a destination.")
	
	match $VBoxContainer/HBoxContainer/OptionButton.get_index():
		0:
			pass
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


## Turns the evil typeless array returned by map's pos_to_tile() method into a nice Vector2i!
func _pos_to_tile_array_to_vector(evil_array: Array) -> Vector2i:
	# This cast is always going to be unsafe as the Array has no specific type :/ Ignore it !
	@warning_ignore("unsafe_call_argument")
	return Vector2i(evil_array[0], evil_array[1])


func depth_first_search() -> void:
	pass


func breadth_first_search() -> bool:
	# Everytyhing is unsafe D: We should build a hand to hold :D
	@warning_ignore("unsafe_method_access", "unsafe_call_argument")
	var starting_tile: Vector2i = _pos_to_tile_array_to_vector(map.pos_to_tile(creep.get_position()))
	@warning_ignore("unsafe_method_access", "unsafe_call_argument")
	var end_tile: Vector2i = _pos_to_tile_array_to_vector(map.pos_to_tile(waypoint.get_position()))
	
	if _debug_print_start_tile:
		print_debug(starting_tile)
	if _debug_print_end_tile:
		print_debug(end_tile)
	
	var distance: int = 0
	while distance <= max(abs(end_tile.x - starting_tile.x), abs(end_tile.y - starting_tile.y)):
		# Check ALL tiles within the square boundary defined by distance
		for i: int in range(starting_tile.x - distance, starting_tile.x + distance + 1):
			for j: int in range(starting_tile.y - distance, starting_tile.y + distance + 1):
				if Vector2i(i, j) == end_tile:
					return true 
		distance += 1
	
	return false
