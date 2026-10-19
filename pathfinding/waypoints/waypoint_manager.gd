#@tool
class_name WaypointManager
extends Node

## In euclidean distance.
@export var max_neighbour_distance: float = 1.0
@export_category("Debug")
#@export_tool_button("Add waypoint")
#var add_waypoint_action = add_waypoint


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if Engine.is_editor_hint():
		#return
	
	for i: int in get_child_count():
		if get_child(i) is not PathfindingWaypoint:
			push_warning("This child is not one of mine! Does it need to find another parent?")
		else:
			for j: int in get_child_count():
				if get_child(i) != get_child(j):
					if (get_child(i) as PathfindingWaypoint).get_position().distance_to((get_child(j) as PathfindingWaypoint).get_position()) <= (get_child(i) as PathfindingWaypoint).get_max_neighbour_distance():
						(get_child(i) as PathfindingWaypoint).get_range_nearby_nodes().append(get_child(j))



# TODO: Developer experience function
#func add_waypoint():
	#var new_waypoint := PathfindingWaypoint.new()
	#add_child(new_waypoint)
	#
	# TODO: Add undo history - https://docs.godotengine.org/en/stable/classes/class_@gdscript.html
