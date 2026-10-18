extends Node

## This should be the character body that wants to be moved from waypoint to waypoint.
@export var host: CharacterBody3D = null

var nearby_waypoints: Array[PathfindingWaypoint] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
