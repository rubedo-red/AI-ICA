extends Node3D


#store boids belonging to the unit within an array
var boidArray: Array[Node3D]=[]
#Starting number of boids when unit is spawned in
var startingBoids
#max distance from the average position between boids
var cohesion

func _init(_boids: int =10, _cohesion: float = 3):
	startingBoids=_boids
	cohesion=_cohesion

func _calc_average_pos() -> Vector3:
	var pos_total: Vector3 =  Vector3(0.0, 0.0, 0.0)
	for boid in boidArray:
		pos_total = boid.position + pos_total
	var pos = Vector3(pos_total.x/boidArray.size(),pos_total.y/boidArray.size(),pos_total.z/boidArray.size())
	return pos

func _spawn_boid(newPosition: Vector3, id: int) -> void:
	var scene: PackedScene = load("res://boid.tscn")
	if scene == null:
		push_error("Failed to load boid: res://boid.tscn")
		return
	
	var instance: Node3D = scene.instantiate()
	
	instance.position = newPosition
	instance.setup(id)
	add_child(instance)
	boidArray.push_back(instance)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	print_debug("	-Boids To Spawn: ", startingBoids)
	
	var x
	var z
	var angle_step = 2*3.14/startingBoids
	var angle
	for i in range(startingBoids):
		#Calculate position around the unit Node3d
		angle=i*angle_step
		x=cohesion*cos(angle)
		z=cohesion*sin(angle)
		var pos: Vector3 = Vector3(position.x+x, position.y, position.z+z)
		
		_spawn_boid(pos, i)
		print("		-Spawned Boids")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = _calc_average_pos()
	for boid in boidArray:
		boid.position.z-= 0.02
	pass
