extends Node3D
## Script used to test waypoint things


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print_debug($WaypointManager/PathfindingWaypoint._get_closest_node_from_array().get_name())
