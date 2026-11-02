extends Node3D

#store boids belonging to the unit within an array
var boidArray: Array[Node3D]=[]
#Starting number of boids when unit is spawned in
var startingBoids
#Previous terrain on last tick stored in an int
var previousTerrain: int = -1
#Previous position on the last tick stored as a Vector3d
var previousTile
#Array holding all other units that overlap into the cohesion bubble
var overlapping_units: Array[Node3D]
@export var stop: bool = false

@export var boid_colour: Color = Color(1, 0, 0)

#Boid variables distributed by the unit
@export var pullStrength:float
@export var cohesionSize:float
@export var seperationSize:float


@export var map: Node3D 

@export var manager: UnitManager
func add_manager() -> void:
	manager = $"../unit_manager"
	if manager:
		manager.add_unit(self)
	else:
		print("Error: Could not find manager")

func remove_unit() -> void:
	if manager:
		manager.remove_unit(self)

func get_units() -> Array[Node3D]:
	return manager.get_units()

func _init(_boids: int =50):
	startingBoids=_boids

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
	
	var instance: Boid = scene.instantiate()
	
	instance.position = newPosition
	instance.setup(id,pullStrength,cohesionSize,seperationSize)
	
	instance.name = "Boid"+str(id)
	add_child(instance)
	boidArray.push_back(instance)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_manager()
	map = $"../Map"
	var x
	var z
	var angle_step = 2*3.14/startingBoids
	var angle
	for i in range(startingBoids):
		angle=i*angle_step
		x=cohesionSize*cos(angle)
		z=cohesionSize*sin(angle)
		var pos: Vector3 = Vector3(position.x+x, position.y, position.z+z)
		
		_spawn_boid(pos, i)
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if manager:
		overlapping_units = manager.get_overlapping_units(self)
	else:
		overlapping_units = []
	
	var t = map.pos_to_tile(global_position)
	#if t !=previousTile:
		#print(" - x: ",t[0],", z: ", t[1])
	var terrain = map.get_tile_index(t[0],t[1])
	#if terrain != previousTerrain:
		#if terrain == 0:
			#print("		- Land")
		#elif terrain == 1:
			#print("		- Water")
		#elif terrain == 2:
			#print("		- Mountain")
		#else:
			#print("		- Not on tile")
	previousTerrain = terrain
	previousTile = t
	
	var target_center = _calc_average_pos()
	
	var position_offset = target_center - global_position
	
	global_position = target_center

	for boid in boidArray:
		boid.global_position -= position_offset
		var distance = boid.global_position.distance_to(global_position)
		
		

	pass
