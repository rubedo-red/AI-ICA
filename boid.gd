class_name Boid
extends Node3D

var id: int
var stop: bool = false
var pullStrength:float
var cohesionSize:float
var seperationSize:float
var forward_dir:Vector3
var distance
var mat 
var copyBoids

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
	global_translate(forward_dir*1.5*delta)

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
			rotation.y = lerp_angle(rotation.y, rotation.y + angle_r * turn_sign, delta * 3.0)
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
		dir_to_other = (boid.global_position - position).normalized()	
		var angle_r = forward_dir.angle_to(dir_to_other)
		var dist = global_position.distance_to(boid.global_position)
		if dist < seperationSize:
			mat.albedo_color = Color(0.917, 0.317, 0.444, 1.0)
			var cross_dir = forward_dir.cross(dir_to_other)
			var turn_sign = sign(cross_dir.y)
			rotation.y = lerp_angle(rotation.y, rotation.y - angle_r * turn_sign, delta * 3)
			mat.albedo_color = Color(1,1,0)
			return false
	return true



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	forward_dir = global_transform.basis.z.normalized()
	rotation.y = randf_range(0,360)
	var mesh_node = get_node("CollisionShape3D/MeshInstance3D") as MeshInstance3D
	mat = mesh_node.get_active_material(0) as StandardMaterial3D	
	if mat and not mesh_node.has_meta("material_duplicated"):
			mat = mat.duplicate()
			mesh_node.set_surface_override_material(0, mat)
			mesh_node.set_meta("material_duplicated", true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	forward_dir = global_transform.basis.z.normalized()
	copyBoids =get_parent_node_3d().get_children()
	var parent_position = get_parent_node_3d().position
	distance = global_position.distance_to(parent_position)
	mat.albedo_color = Color(1,1,1)
	
	
	if  _seperation_test(delta) and _cohesion_test(distance,parent_position,delta):
		if stop == false:
			_direction_move(delta)
	else:
		_direction_move(delta)
	
	
	pass
