extends Node

var id: int

func setup( boid_id : int = 0) -> void: 
	id=boid_id
	var label_node := $CollisionShape3D/MeshInstance3D/bLabel
	label_node.text = str(id)
	print("			-Boid ", id, " Ready")
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	 
	pass
