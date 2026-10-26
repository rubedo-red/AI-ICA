extends Node3D

enum terrain_types { land, water, mountain }

@export var width : int = 10
		
@export var height : int = 10
		
@export var cell_size: float = 2.0
		
@onready var terrain = $terrain

var noise: FastNoiseLite = FastNoiseLite.new()

var cells : PackedByteArray = [0]

func update_mesh():
	var plane := PlaneMesh.new()
	plane.subdivide_depth = height*4
	plane.subdivide_width = width*4
	plane.size = Vector2(width*cell_size, height*cell_size)
	
	var plane_arrays := plane.get_mesh_arrays()
	var vertex_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	for i in vertex_array.size():
		var vertex := vertex_array[i]
		var celltype: terrain_types = pos_to_tile_type(vertex)
		if noise:
			match celltype:
				terrain_types.water:
					vertex.y -= 2.0
				terrain_types.land:
					vertex.y += noise.get_noise_2d(vertex.x*4.0, vertex.z*4.0) * 2.0
		vertex_array[i] = vertex
	
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	terrain.mesh = array_mesh

func pos_to_tile(pos: Vector3):
	var relative =  pos - global_position 
	relative.x = relative.x+(width*cell_size)/2
	relative.z = relative.z+(height*cell_size)/2
	var x = int(floor(relative.x/cell_size))
	var y = int(floor(relative.z/cell_size))

	return [x, y]
	
func pos_to_tile_type(pos: Vector3) -> terrain_types:
	var relative =  pos - global_position 
	relative.x = relative.x+(width*cell_size)/2
	relative.z = relative.z+(height*cell_size)/2
	var x = int(floor(relative.x/cell_size))
	var y = int(floor(relative.z/cell_size))
	if (x >= width or y >= height):
		return 0

	return cells[x + y*width]

func get_tile_index(x: int, y: int):
	if x < 0 or x >= width or y < 0 or y >= height:
		return -1
	return cells[x+y*width]

@export var land_weight = 6;
@export var water_weight = 4;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_grid()
	update_mesh()
	
	
func get_neighbour_count(index: int):
	var x = index%height
	var y: int = index/width
	var count = 0
	for n in range(-1, 2):
		for m in range(-1, 2):
			var checkx = m+x 
			var checky = n+y
			if (checkx>=0 and checkx<width and checky>=0 and checky<height):
				count += min(cells.get(checkx+checky*width), 1) 
			else:
				count += 1
	return count-min(cells[index],1)

@export var survive_min =  3
@export var reproduce_min = 6

func iterate_automata():
	var new_cells = PackedByteArray()
	new_cells.resize(width*height)
	for i in width*height:
		new_cells[i] = cells[i]
		var neighbours = get_neighbour_count(i)
		if (neighbours < survive_min): new_cells[i] = 0
		if (neighbours > reproduce_min): new_cells[i] = 1
	cells = new_cells  
	
func generate_grid():
	cells.resize(width*height)
	for i in width*height:
		cells.set(i, min(randi()%(land_weight+water_weight)/land_weight, 1))
	for i in 100:
		iterate_automata()
	
