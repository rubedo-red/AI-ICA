# BUG: https://github.com/godotengine/godot/issues/66381
@tool
class_name PathfindingWaypoint
extends Node3D

## Variant 1 requires the manual specification of valid nodes.
## Varient 2 takes a max neighbour range value and any nodes in range get added.
enum WaypointVariant { MANUAL, RANGE }
enum NextWaypointCriteria { CLOSEST = -5, NORTH = -4, EAST = -3, SOUTH = -2, WEST = -1 }

@export var waypoint_variant: WaypointVariant = WaypointVariant.MANUAL
@export_category("Varient 1")
@export var manual_nearby_nodes: Array[PathfindingWaypoint] = []
@export_category("Varient 2")
## In euclidean distance.
@export var max_neighbour_distance: float = 10.0
@export_category("Debug")
@export var _debug_visible: bool = false
@export var _debug_range_visible: bool = false
# TODO: Gross hardcoded string.
@export var _debug_range_mesh_shader: Shader = preload("res://pathfinding/wireframe.gdshader")
@export var _debug_range_mesh_shader_colour: Color = Color.BLACK
@export var _debug_print_found_node_in_range: bool = false

var range_nearby_nodes: Array[PathfindingWaypoint] = []

# Debug vars
var debug_mesh: MeshInstance3D = null
var debug_range_mesh: MeshInstance3D = null


func _ready() -> void:
	# Editor stuff in here only - we skip the rest of _ready().
	if Engine.is_editor_hint():
		debug_mesh = _create_debug_mesh()
		debug_range_mesh = _create_debug_range_mesh()
		return
	
	set_debug_mesh_visible(_debug_visible)
	set_debug_range_mesh_visible(_debug_range_visible)
	
	if get_parent() is not WaypointManager:
		push_warning(self, " is not a child of a WaypointManager, so wont be able to find any other waypoint automatically :(")
	
	if waypoint_variant == WaypointVariant.MANUAL and manual_nearby_nodes.size() == 0:
		push_warning("This node requires nearby nodes to be manually specified, but no nodes have been specified.")
	
	# NOTE: RANGE variants should be children of a WaypointManager
	if waypoint_variant == WaypointVariant.RANGE:
		#range_nearby_nodes = find_nearby_nodes()
		pass


func get_max_neighbour_distance() -> float:
	return max_neighbour_distance

#region Debug
#region debug_mesh
func _create_debug_mesh() -> MeshInstance3D:
	var shape: BoxMesh = BoxMesh.new()
	shape.set_size(Vector3(0.2, 0.2, 0.2))
	
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.set_mesh(shape)
	
	add_child(mesh)
	
	return mesh


func is_debug_mesh_visible() -> bool:
	if debug_mesh == null:
		debug_mesh = _create_debug_mesh()
	
	return debug_mesh.is_visible()


func set_debug_mesh_visible(visibility: bool) -> void:
	if debug_mesh == null:
		debug_mesh = _create_debug_mesh()
	
	debug_mesh.set_visible(visibility)
	
	_debug_visible = visibility
#endregion


#region debug_range_mesh
func _create_debug_range_mesh() -> MeshInstance3D:
	var mesh: MeshInstance3D = _create_debug_mesh()
	if mesh.get_mesh() is not BoxMesh:
		push_warning("This function needs updating if the debug mesh is anything other than a box!")
		return mesh
	(mesh.get_mesh() as BoxMesh).set_size(Vector3(max_neighbour_distance, max_neighbour_distance, max_neighbour_distance))
	
	if _debug_range_mesh_shader == null:
		push_warning("debug_range_mesh_shader_material is null. Enjoy the big box!")
	else:
		var shader_material: ShaderMaterial = ShaderMaterial.new()
		shader_material.set_shader(_debug_range_mesh_shader)
		
		shader_material.set_shader_parameter("wireframeColor", _debug_range_mesh_shader_colour)
		shader_material.set_shader_parameter("width", 2.0)
		shader_material.set_shader_parameter("modelOpacity", 0.0)
		
		(mesh.get_mesh() as BoxMesh).set_material(shader_material)
	
	return mesh


func is_debug_range_mesh_visible() -> bool:
	if debug_range_mesh == null:
		debug_range_mesh = _create_debug_range_mesh()
	
	return debug_range_mesh.is_visible()


func set_debug_range_mesh_visible(visibility: bool) -> void:
	if debug_range_mesh == null:
		debug_range_mesh = _create_debug_range_mesh()
	
	debug_range_mesh.set_visible(visibility)
	
	_debug_visible = visibility
#endregion
#endregion


func get_range_nearby_nodes() -> Array[PathfindingWaypoint]:
	return range_nearby_nodes


func get_nearby_node(criteria: int) -> PathfindingWaypoint:
	if range_nearby_nodes.is_empty():
		push_error("Cannot get next node as range_nearby_nodes is empty :(")
		return null
	
	# Match criteria, otherwise get waypoint from the waypoint array
	match criteria:
		NextWaypointCriteria.CLOSEST:
			return _get_closest_node_from_array()
		NextWaypointCriteria.NORTH:
			push_error("Not implemented. Will return null!")
			return null
		NextWaypointCriteria.EAST:
			push_error("Not implemented. Will return null!")
			return null
		NextWaypointCriteria.SOUTH:
			push_error("Not implemented. Will return null!")
			return null
		NextWaypointCriteria.WEST:
			push_error("Not implemented. Will return null!")
			return null
		_:
			# Use criteria as array index. Cannot be less than 0, cannot be more than array size - 1
			if not criteria < 0 or not criteria > range_nearby_nodes.size() - 1:
				return range_nearby_nodes[criteria]
	
	return null


func _get_closest_node_from_array() -> PathfindingWaypoint:
	if range_nearby_nodes.is_empty():
		push_error("Array is empty. We cannot do anything?")
		# TODO: Don't return null - Although we should never need to use this block of code
		return null
	
	var closest_node_index: int = 0
	for i: int in range_nearby_nodes.size() - 2:
		if range_nearby_nodes[closest_node_index].get_position().distance_squared_to(get_position()) > range_nearby_nodes[i+ 1].get_position().distance_squared_to(get_position()):
			print_debug(range_nearby_nodes[closest_node_index].name, " is further away than ", range_nearby_nodes[i + 1])
			closest_node_index = i + 1
	
	return range_nearby_nodes[closest_node_index]
