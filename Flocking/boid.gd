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

@onready var raycast: RayCast3D = $RayCast3D





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
func _cohesion_test(dist : float, parent_pos: Vector3, delta:float , strength: float) ->bool:
	var dir_to_parent: Vector3 = (parent_pos - global_transform.origin).normalized()
	var angle_r = forward_dir.angle_to(dir_to_parent)
	var angle_d = rad_to_deg(angle_r)
	
	if dist > cohesionSize:	
		mat.albedo_color = Color(1,0.6,0)
		if angle_d>10:
			var cross_dir = forward_dir.cross(dir_to_parent)
			var turn_sign = sign(cross_dir.y)
			rotation.y = lerp_angle(rotation.y, rotation.y + angle_r * turn_sign, delta * strength)
			mat.albedo_color = Color(1, 0, 0)
			return false
	return true

# makes boids stay away from each other
func _seperation_test(delta:float, strength: float)->bool:
	
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
			rotation.y = lerp_angle(rotation.y, rotation.y - angle_r * turn_sign, delta * strength)
			mat.albedo_color = Color(1,1,0)
			return false
	return true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unit = get_parent()
	
	
	
	
	
	for a in $Guy_v0_1.get_children():
		
		if a.name.contains("Body"):
			var b_mat := StandardMaterial3D.new()
			b_mat.albedo_color = unit.boid_colour
			a.set_surface_override_material(0,b_mat) 
			continue
		var a0_mat := StandardMaterial3D.new()
		var a1_mat := StandardMaterial3D.new()
		a0_mat.albedo_color = unit.boid_accessory_0_colour
		a0_mat.metallic = 1
		a0_mat.roughness = 0.2
		a.set_surface_override_material(0,a0_mat) 
		a1_mat.albedo_color = unit.boid_accessory_1_colour
		a1_mat.metallic = 0.0
		a1_mat.roughness = 0.5
		a.set_surface_override_material(1,a1_mat) 
		if randi_range(0,3)  == 0 and not a.name.contains("0"):
			a.visible = false
	
	
	
	forward_dir = global_transform.basis.z.normalized()
	rotation.y = randf_range(0,360)
	var mesh_node = get_node("CollisionShape3D/MeshInstance3D") as MeshInstance3D
	mat = mesh_node.get_active_material(0) as StandardMaterial3D	
	if mat and not mesh_node.has_meta("material_duplicated"):
			mat = mat.duplicate()
			mesh_node.set_surface_override_material(0, mat)
			mesh_node.set_meta("material_duplicated", true)
	pass # Replace with function body.

# finds other units and moves them away from each other
func _bubble_repulsion_test(delta: float, strength: float) -> bool:
	
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

		global_rotation.y = lerp_angle(global_rotation.y, global_rotation.y + angle_r * turn_sign,delta * strength)
		return true

	return true

func _height_test(delta: float, strength: float)->bool:
	#mat.albedo_color = Color(0.0, 0.0, 0.0, 1.0)
	if !is_zero_approx(global_position.y - 0.5):
		#mat.albedo_color = Color(0.0, 12.051, 0.0, 1.0)
		var targetPos:Vector3
		const EPSILON:=0.01
		
		#print(copyBoids.size())
		for boid in copyBoids:
		#	print(boid.global_position)
			if !abs(boid.global_position.y - 0.5) < EPSILON:
				targetPos = boid.global_position
				break
		#print(targetPos)
		if targetPos.is_zero_approx():
		#	mat.albedo_color = Color(9.2, 0.321, 12.051, 1.0)
			return false
		
		var dir_to_target: Vector3 = (targetPos - global_transform.origin).normalized()
		var angle_r = forward_dir.angle_to(dir_to_target)
		var cross_dir = forward_dir.cross(dir_to_target)
		var turn_sign = sign(cross_dir.y)
		rotation.y = lerp_angle(rotation.y, rotation.y + angle_r * turn_sign, delta * strength)
		#mat.albedo_color = Color(0.0, 11.568, 14.033, 1.0)
		return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	forward_dir = global_transform.basis.z.normalized()
	copyBoids =get_parent_node_3d().get_children()
	var parent_position = get_parent_node_3d().position
	distance = global_position.distance_to(parent_position)
	mat.albedo_color = Color(1,1,1)
	
	if raycast.is_colliding():
		var ground_point = raycast.get_collision_point()
		global_position.y = ground_point.y

	var height:bool = _height_test(delta,3)
	
	
	var repulsion:bool = _bubble_repulsion_test(delta,2)
	if !repulsion:
		_direction_move(delta) 
		return
	
	
	
	var seperation:bool = _seperation_test(delta,1.5)
	var cohesion:bool = _cohesion_test(distance,parent_position,delta,3)
	
	if !seperation and !cohesion:
		_direction_move(delta) 
		
	if unit.overlapping_units == null:
		_direction_move(delta)
		return
	
	if unit.stop == false:
		_direction_move(delta)
		return
	
	pass
