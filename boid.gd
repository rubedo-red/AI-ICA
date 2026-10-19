extends Node3D

var id: int
var pullStrength:float
var cohesionSize:float
var seperationSize:float
var forward_dir:Vector3
var mat 

func setup( boid_id : int = 0, boid_cohesion_strength : float = 1,boid_cohesion_size : float = 3.0, boid_seperation_size : float = 0.3 ) -> void:
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
	global_rotation.y += randf_range(-0.05,0.05)
	forward_dir = transform.basis.z
	global_translate(forward_dir*.5*delta)

# keeps all boids within range of one another by using their average position and pulling them back when they leave the cohesion bubble
func _cohesion_test(dist : float, parent_pos: Vector3, delta:float ) ->void:
	var dir_to_parent: Vector3 = (parent_pos - position).normalized()
	var angle_r = forward_dir.angle_to(dir_to_parent)
	var angle_d = rad_to_deg(angle_r)
	if dist > cohesionSize:	
		if angle_d > 60:
			rotation_degrees.y -= angle_d*pullStrength*delta
			mat.albedo_color = Color(1,0,0)

func _seperation_test(delta:float)->void:
	var boids = get_parent_node_3d().get_children()
	var dir_to_other: Vector3 
	for boid in boids:
		if boid.name == name:
			continue
		dir_to_other = (boid.global_position - position).normalized()	
		var angle_r = forward_dir.angle_to(dir_to_other)
		var angle_d = rad_to_deg(angle_r)
		var dist = global_position.distance_to(boid.global_position)
		if dist < seperationSize:
			
			rotation_degrees.y += angle_d*pullStrength*delta
			boid.rotation_degrees.y -= angle_d*pullStrength*delta
			mat.albedo_color = Color(1,1,0)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	var parent_position = get_parent_node_3d().position
	var distance = global_position.distance_to(parent_position)
	mat.albedo_color = Color(1,1,1)
	_cohesion_test(distance,parent_position,delta)
	_seperation_test(delta)
	_direction_move(delta)
	
	
	pass
