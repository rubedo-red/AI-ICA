extends Node

## This should be the character body that wants to be moved from waypoint to waypoint.
@export var host: CharacterBody3D = null
## Add a waypoint manager so we can get nearby nodes
@export var waypoint_manager: WaypointManager = null

var current_waypoint: PathfindingWaypoint = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func move_to_waypoint(criteria: int) -> bool:
	# Make an effort
	if current_waypoint == null:
		current_waypoint = find_nearest_waypoint()
	
	if current_waypoint == null:
		push_warning("Could not find any nearby waypoints :( This might be an issue with waypoint_manager and it's children!")
		return false
	
	current_waypoint = current_waypoint.get_nearby_node(criteria)
	
	if current_waypoint == null:
		push_warning("Our current node has no nearby nodes D:")
	
	return current_waypoint != null


func find_nearest_waypoint() -> PathfindingWaypoint:
	if waypoint_manager == null:
		push_error("Cannot find nearest waypoint as pathfinding_manager is null!")
		return null
	
	return waypoint_manager.find_nearest_waypoint_to_position(host.get_position())
