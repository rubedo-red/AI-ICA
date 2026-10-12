extends Node3D

var id: int
var pullStrength:float
var cohesionSize:float
var seperationSize:float

func setup( boid_id : int = 0, boid_cohesion_strength : float = 0.25,boid_cohesion_size : float = 3.0, boid_seperation_size : float = 0.1 ) -> void:
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
	global_position.z += randf_range(-1,1)* delta

# keeps all boids within range of one another by using their average position and pulling them back when they leave the cohesion bubble
func _cohesion_test(dist : float, parent_pos: Vector3, delta:float ) ->void:
	if dist > cohesionSize:
		var direction = (parent_pos - global_position).normalized()
		global_position += direction * pullStrength * delta

func _alignment_test():
	print()

func _seperation_test(delta : float):
	print()
	var boids =get_parent_node_3d().get_children()
	for boid in boids:
		if name == boid.name:
			continue
		var distance = global_position.distance_to(boid.global_position)
		if distance < seperationSize:
			var direction = (boid.global_position - global_position).normalized()
			global_position += direction * 0.1 * delta

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var parent_position = get_parent_node_3d().position
	var distance = global_position.distance_to(parent_position)
	
	_random_move(delta)
	_cohesion_test(distance,parent_position,delta)
	_seperation_test(delta)
	
	pass
