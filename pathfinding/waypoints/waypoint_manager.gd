#@tool
class_name WaypointManager
extends Node

## Waypoint Manager groups waypoints together, 

@export_category("Debug")
@export var debug_force_show_waypoint_debug_mesh: bool = false
@export var debug_force_show_waypoint_debug_range_mesh: bool = false
#@export_tool_button("Add waypoint")
#var add_waypoint_action = add_waypoint


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if Engine.is_editor_hint():
		#return
	
	# Debug stuff
	if debug_force_show_waypoint_debug_mesh:
		for i: int in get_child_count():
			if get_child(i) is PathfindingWaypoint:
				(get_child(i) as PathfindingWaypoint).set_debug_mesh_visible(true)
	
	if debug_force_show_waypoint_debug_range_mesh:
		for i: int in get_child_count():
			if get_child(i) is PathfindingWaypoint:
				(get_child(i) as PathfindingWaypoint).set_debug_range_mesh_visible(true)
	
	# Autopopulate nearby nodes for all children. Probably expensive!
	# We need to know the exact distance? We cannot use distance_squared_to().
	for i: int in get_child_count():
		if get_child(i) is not PathfindingWaypoint:
			push_warning("This child is not one of mine! Does it need to find another parent?")
		else:
			for j: int in get_child_count():
				if get_child(i) != get_child(j):
					if (get_child(i) as PathfindingWaypoint).get_position().distance_to((get_child(j) as PathfindingWaypoint).get_position()) <= (get_child(i) as PathfindingWaypoint).get_max_neighbour_distance():
						(get_child(i) as PathfindingWaypoint).get_range_nearby_nodes().append(get_child(j))


# Find any waypoint that is a child of a single waypoint manager
# buffer_zone is the diameter of the sphere with the waypoint's position as the origin
func find_nearest_waypoint_to_position(current_position: Vector3, buffer_zone: Vector3 = Vector3.ZERO) -> PathfindingWaypoint:
	for i: int in get_child_count():
		if get_child(i) is not PathfindingWaypoint:
			push_warning("This child is not one of mine! Does it need to find another parent?")
		else:
			if (get_child(i) as PathfindingWaypoint).get_position() != current_position:
				return get_child(i) as PathfindingWaypoint
	
	return null

# TODO: Developer experience function
#func add_waypoint():
	#var new_waypoint := PathfindingWaypoint.new()
	#add_child(new_waypoint)
	#
	# TODO: Add undo history - https://docs.godotengine.org/en/stable/classes/class_@gdscript.html
