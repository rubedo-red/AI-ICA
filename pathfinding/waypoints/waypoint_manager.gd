class_name WaypointManager
extends Node

## In euclidean distance.
@export var max_neighbour_distance: float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i: int in get_child_count():
		if get_child(i) is not PathfindingWaypoint:
			push_warning("This child is not one of mine! Does it need to find another parent?")
		else:
			for j: int in get_child_count():
				if get_child(j) != get_child(i):
					if (get_child(j) as PathfindingWaypoint).get_position().distance_to((get_child(i) as PathfindingWaypoint).get_position()) <= max_neighbour_distance:
						(get_child(j) as PathfindingWaypoint).get_range_nearby_nodes().append(get_child(i))
	
	print_debug((get_child(0) as PathfindingWaypoint).get_range_nearby_nodes().size())
