extends Node3D


#store boids belonging to the unit within an array
var boidArray: Array[Node3D]=[]
#Starting number of boids when unit is spawned in
var startingBoids
#max distance from the average position between boids
var cohesion


@export var map: Node3D

func _init(_boids: int =30, _cohesion: float = 3):
	startingBoids=_boids
	cohesion=_cohesion

func _calc_average_pos() -> Vector3:
	var pos_total: Vector3 = Vector3.ZERO
	for boid in boidArray:
		pos_total += boid.global_position
	pos_total/= boidArray.size()
	return pos_total.snapped(Vector3(0.001,0.001,0.001))

func _spawn_boid(newPosition: Vector3, id: int) -> void:
	var scene: PackedScene = load("res://boid.tscn")
	if scene == null:
		push_error("Failed to load boid: res://boid.tscn")
		return
	
	var instance: Node3D = scene.instantiate()
	
	instance.position = newPosition
	instance.setup(id)
	
	instance.name = "Boid"+str(id)
	add_child(instance)
	boidArray.push_back(instance)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	var x
	var z
	var angle_step = 2*3.14/startingBoids
	var angle
	for i in range(startingBoids):
		angle=i*angle_step
		x=cohesion*cos(angle)
		z=cohesion*sin(angle)
		var pos: Vector3 = Vector3(position.x+x, position.y, position.z+z)
		
		_spawn_boid(pos, i)
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	var t = map.pos_to_tile(global_position)
	
	var target_center = _calc_average_pos()
	
	var position_offset = target_center - global_position
	
	global_position = target_center

	for boid in boidArray:
		boid.global_position -= position_offset
		var distance = boid.global_position.distance_to(global_position)
		
		var mesh_node = boid.get_node("CollisionShape3D/MeshInstance3D") as MeshInstance3D
		
		var mat = mesh_node.get_active_material(0) as StandardMaterial3D		
		if mat and not mesh_node.has_meta("material_duplicated"):
			mat = mat.duplicate()
			mesh_node.set_surface_override_material(0, mat)
			mesh_node.set_meta("material_duplicated", true)

		if mat:
			if distance > cohesion:
				mat.albedo_color = Color(1, 0, 0) 
			else:
				mat.albedo_color = Color(0, 0, 1) 

	pass
