# BUG: https://github.com/godotengine/godot/issues/66381
@tool
class_name PathfindingWaypoint
extends Node3D

## Variant 1 requires the manual specification of valid nodes.
## Varient 2 takes a max neighbour range value and any nodes in range get added.
enum WaypointVariant { MANUAL, RANGE }

@export var waypoint_variant: WaypointVariant = WaypointVariant.MANUAL
@export_category("Varient 1")
@export var manual_nearby_nodes: Array[PathfindingWaypoint] = []
@export_category("Varient 2")
@export var max_neighbour_distance: float = 10.0
@export_category("Debug")
@export var debug_visible: bool = false
# TODO: Gross hardcoded string.
@export var debug_range_mesh_shader: Shader = preload("res://pathfinding/wireframe.gdshader")
@export var debug_range_mesh_shader_colour: Color = Color.BLACK
@export var debug_print_found_node_in_range: bool = false

var range_nearby_nodes: Array[PathfindingWaypoint] = []

# Debug vars
var debug_mesh: MeshInstance3D = null
var debug_range_mesh: MeshInstance3D = null


func _ready() -> void:
	# Editor stuff in here only - we skip the rest of _ready().
	if Engine.is_editor_hint():
		_create_debug_mesh()
		_create_debug_range_mesh()
		return
	
	set_debug_mesh_visible(debug_visible)
	
	
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


func _create_debug_mesh() -> MeshInstance3D:
	var shape: BoxMesh = BoxMesh.new()
	shape.set_size(Vector3(0.2, 0.2, 0.2))
	
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.set_mesh(shape)
	
	debug_mesh = mesh
	
	add_child(mesh)
	
	return mesh


func is_debug_mesh_visible() -> bool:
	if debug_mesh == null:
		_create_debug_mesh()
	
	return debug_mesh.is_visible()


func set_debug_mesh_visible(visibility: bool) -> void:
	if debug_mesh == null:
		_create_debug_mesh()
	
	debug_mesh.set_visible(visibility)
	
	debug_visible = visibility


func _create_debug_range_mesh() -> MeshInstance3D:
	var mesh: MeshInstance3D = _create_debug_mesh()
	if mesh.get_mesh() is not BoxMesh:
		push_warning("This function needs updating if the debug mesh is anything other than a box!")
		return mesh
	(mesh.get_mesh() as BoxMesh).set_size(Vector3(max_neighbour_distance, max_neighbour_distance, max_neighbour_distance))
	
	if debug_range_mesh_shader == null:
		push_warning("debug_range_mesh_shader_material is null. Enjoy the big box!")
	else:
		var shader_material = ShaderMaterial.new()
		shader_material.set_shader(debug_range_mesh_shader)
		
		shader_material.set_shader_parameter("wireframeColor", debug_range_mesh_shader_colour)
		shader_material.set_shader_parameter("width", 2.0)
		shader_material.set_shader_parameter("modelOpacity", 0.0)
		
		(mesh.get_mesh() as BoxMesh).set_material(shader_material)
	
	debug_range_mesh = mesh
	
	return mesh

func get_range_nearby_nodes() -> Array[PathfindingWaypoint]:
	return range_nearby_nodes
