class_name PathfindingWaypoint
extends Node3D

## Variant 1 requires the developer to manually specify valid nodes.
## Varient 2 takes a range value and any nodes in range get added.
enum WaypointVariant { MANUAL, RANGE }

@export var waypoint_variant: WaypointVariant = WaypointVariant.MANUAL
@export_category("Varient 1")
@export var manual_nearby_nodes: Array[PathfindingWaypoint] = []
@export_category("Varient 2")
@export var shape_cast_3d_size: Vector3 = Vector3.ONE
@export_category("Debug")
@export var debug_visible: bool = false
@export var debug_print_found_node_in_range: bool = false

@onready var debug_mesh: MeshInstance3D = null

var range_nearby_nodes: Array[PathfindingWaypoint] = []


func _ready() -> void:
	if debug_visible:
		var shape: BoxMesh = BoxMesh.new()
		shape.set_size(Vector3(0.2, 0.2, 0.2))
		
		var mesh: MeshInstance3D = MeshInstance3D.new()
		mesh.set_mesh(shape)
		
		debug_mesh = mesh
		
		add_child(mesh)
	
	if get_parent() is not WaypointManager:
		push_warning(self, " is not a child of a WaypointManager, so wont be able to find any other waypoint automatically :(")
	
	if waypoint_variant == WaypointVariant.MANUAL and manual_nearby_nodes.size() == 0:
		push_warning("This node requires nearby nodes to be manually specified, but no nodes have been specified.")
	
	# NOTE: RANGE variants should be children of a WaypointManager
	if waypoint_variant == WaypointVariant.RANGE:
		#range_nearby_nodes = find_nearby_nodes()
		pass


func is_debug_mesh_visible() -> bool:
	if debug_mesh == null:
		push_warning("Debug mesh is null. Cannot get its current visibility.")
		return false
	
	return debug_mesh.is_visible()


func set_debug_mseh_visible(visibility: bool) -> bool:
	if debug_mesh == null:
		push_warning("Debug mesh is null. Cannot set visibility.")
		return false
	
	debug_mesh.set_visible(visibility)
	
	debug_visible = visibility
	
	return true


func get_range_nearby_nodes() -> Array[PathfindingWaypoint]:
	return range_nearby_nodes


func find_nearby_nodes() -> Array[PathfindingWaypoint]:
	var found_nodes: Array[PathfindingWaypoint] = []
	
	var shape: BoxShape3D = BoxShape3D.new()
	shape.set_size(shape_cast_3d_size)
	
	var shape_cast: ShapeCast3D = ShapeCast3D.new()
	shape_cast.set_shape(shape)
	add_child(shape_cast)
	
	if shape_cast.get_collision_count() == 0:
		push_warning("Waypoint ", self, " found no other waypoints nearby :(")
	else:
		for i: int in shape_cast.get_collision_count():
			if shape_cast.get_collider(i) is PathfindingWaypoint:
				found_nodes.append(shape_cast.get_collider(i))
				
				if debug_print_found_node_in_range:
					print_debug("Waypoint ", self, " found waypoint ", shape_cast.get_collider(i))
	
	return found_nodes
