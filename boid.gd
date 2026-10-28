class_name Boid
extends Node3D

var id: int

var pullStrength:float
var cohesionSize:float
var seperationSize:float
var forward_dir:Vector3
var distance
var mat 
var copyBoids
var unit: Node3D




func setup( boid_id : int = 0, boid_cohesion_strength : float = 1.0,boid_cohesion_size : float = 3.0, boid_seperation_size : float = 0.6 ) -> void:
	id=boid_id
	pullStrength = boid_cohesion_strength
	cohesionSize = boid_cohesion_size
	seperationSize = boid_seperation_size
	var label_node := $CollisionShape3D/MeshInstance3D/bLabel
	label_node.text = str(id)
	

# random jitter for debug
func _random_move(delta:float):
	global_position.x += randf_range(-1,1)* delta
	#global_position.y += randf_range(-1,1)* delta
	global_position.z += randf_range(-1,1.3)* delta

func _direction_move(delta:float):
	if distance <cohesionSize:
		global_rotation.y += randf_range(-0.05,0.05)
	global_translate(forward_dir*randf_range(1.0,1.5)*delta)

# keeps all boids within range of one another by using their average position and pulling them back when they leave the cohesion bubble
func _cohesion_test(dist : float, parent_pos: Vector3, delta:float ) ->bool:
	var dir_to_parent: Vector3 = (parent_pos - global_transform.origin).normalized()
	var angle_r = forward_dir.angle_to(dir_to_parent)
	var angle_d = rad_to_deg(angle_r)
	
	if dist > cohesionSize:	
		mat.albedo_color = Color(1,0.6,0)
		if angle_d>10:
			var cross_dir = forward_dir.cross(dir_to_parent)
			var turn_sign = sign(cross_dir.y)
			rotation.y = lerp_angle(rotation.y, rotation.y + angle_r * turn_sign, delta * 2.5)
			mat.albedo_color = Color(1, 0, 0)
			return false
	return true

func _seperation_test(delta:float)->bool:
	var dir_to_other: Vector3 
	if distance >cohesionSize:
		return	true
		
	for boid in copyBoids:
		if boid.name == name:
			continue
		
		var dist = global_position.distance_to(boid.global_position)
		if dist < seperationSize:
			dir_to_other = (boid.global_position - global_position).normalized()	
			var angle_r = forward_dir.angle_to(dir_to_other)
			mat.albedo_color = Color(0.917, 0.317, 0.444, 1.0)
			var cross_dir = forward_dir.cross(dir_to_other)
			var turn_sign = sign(cross_dir.y)
			rotation.y = lerp_angle(rotation.y, rotation.y - angle_r * turn_sign, delta * 1.5)
			mat.albedo_color = Color(1,1,0)
			return false
	return true



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unit = get_parent()
	
	if unit == null or not "boid_colour" in unit:
		print("Error: Parent node is missing or does not contain 'boid_colour'")
		return
	var boid_mesh = get_node("Guy_v0_1/Cube") as MeshInstance3D
	var boid_mat = boid_mesh.get_active_material(0) as StandardMaterial3D	
	
	if boid_mat and not boid_mesh.has_meta("material_duplicated"):
		boid_mat = boid_mat.duplicate() as StandardMaterial3D
		boid_mesh.set_surface_override_material(0, boid_mat)
		boid_mesh.set_meta("material_duplicated", true)
		
	if boid_mat:
		boid_mat.albedo_color = unit.boid_colour
	
	forward_dir = global_transform.basis.z.normalized()
	rotation.y = randf_range(0,360)
	var mesh_node = get_node("CollisionShape3D/MeshInstance3D") as MeshInstance3D
	mat = mesh_node.get_active_material(0) as StandardMaterial3D	
	if mat and not mesh_node.has_meta("material_duplicated"):
			mat = mat.duplicate()
			mesh_node.set_surface_override_material(0, mat)
			mesh_node.set_meta("material_duplicated", true)
	pass # Replace with function body.



func _bubble_repulsion_test(delta: float) -> bool:
	if not unit or unit.overlapping_units.is_empty():
		return true

	var repulsion_force: Vector3 = Vector3.ZERO
	var within_cohesion: bool = false

	for other_unit in unit.overlapping_units:
		var dist_to_other = global_position.distance_to(other_unit.global_position)

		if dist_to_other < other_unit.cohesionSize:
			within_cohesion = true
			var push_dir = (global_position - other_unit.global_position).normalized()

			var depth = other_unit.cohesionSize - dist_to_other
			repulsion_force += push_dir * depth

	if within_cohesion and repulsion_force != Vector3.ZERO:
		mat.albedo_color = Color(0, 0, 1)

		var push_dir_normalized = repulsion_force.normalized()
		var angle_r = forward_dir.angle_to(push_dir_normalized)
		var cross_dir = forward_dir.cross(push_dir_normalized)
		var turn_sign = sign(cross_dir.y)

		global_rotation.y = lerp_angle(global_rotation.y, global_rotation.y + angle_r * turn_sign,delta * 1.5)
		return true

	return true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	forward_dir = global_transform.basis.z.normalized()
	copyBoids =get_parent_node_3d().get_children()
	var parent_position = get_parent_node_3d().position
	distance = global_position.distance_to(parent_position)
	mat.albedo_color = Color(1,1,1)
	
	var repulsion:bool = _bubble_repulsion_test(delta)
	if !repulsion:
		_direction_move(delta) 
		return
	
	var seperation:bool = _seperation_test(delta)
	var cohesion:bool = _cohesion_test(distance,parent_position,delta)
	
	if !seperation and !cohesion:
		_direction_move(delta) 
		
	if unit.overlapping_units == null:
		_direction_move(delta)
		return
	
	if unit.stop == false:
		_direction_move(delta)
		return
	
	pass
