extends Node3D

var id: int
var pullStrength:float
var cohesionSize:float

func setup( boid_id : int = 0, boid_cohesion_strength : float = 0.4,boid_cohesion_size : float = 3.0 ) -> void: 
	id=boid_id
	pullStrength = boid_cohesion_strength
	cohesionSize = boid_cohesion_size
	var label_node := $CollisionShape3D/MeshInstance3D/bLabel
	label_node.text = str(id)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var parent_position = get_parent_node_3d().position
	var distance = global_position.distance_to(parent_position)
	
	global_position.x += randf_range(-4,4)* delta
	global_position.y += randf_range(-4,4)* delta
	global_position.z += randf_range(-4,4)* delta
	
	if distance > cohesionSize:
		var direction = (parent_position - global_position).normalized()
		global_position += direction * pullStrength * delta
	
	pass
