class_name Map
extends Node3D

enum terrain_types { land, water, mountain }

@export var width : int = 8
		
@export var height : int = 8
		
@export var cell_size: float = 8.0

@export var cell_resolution: float = 32.0

@onready var terrain = $terrain

@export_range(0.0, 1.0, 0.05) var land_height := 0.40
@export_range(0.0, 1.0, 0.05) var mountain_height := 0.60

@export var noise_resolution: float = 20.0
var height_noise: FastNoiseLite = FastNoiseLite.new()
var biome_noise: FastNoiseLite = FastNoiseLite.new()

var cells : PackedByteArray = [0]

@export var biome_ease_height := 0.15

func biome_value_to_height(val: float) -> float:
	var m = 1.0
	var l = 0.0
	var w = -0.5
	var result = 0.0
	
	if (val > mountain_height+biome_ease_height):
		result = m
	elif (val > mountain_height):
		result = lerpf(l, m, (1.0/biome_ease_height)*(val-(mountain_height)))
	elif (val > land_height):
		result = l
	elif (val > land_height-biome_ease_height):
		result = lerpf(w, l, (1.0/biome_ease_height)*(val-(land_height-biome_ease_height)))
	else: result = w
	
	return result

func update_mesh():
	var plane := PlaneMesh.new()
	plane.subdivide_depth = height*cell_resolution
	plane.subdivide_width = width*cell_resolution
	plane.size = Vector2(width*cell_size, height*cell_size)
	
	var plane_arrays := plane.get_mesh_arrays()
	var vertex_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_NORMAL]
	for i in vertex_array.size():
		var vertex := vertex_array[i]
		var celltype: terrain_types = pos_to_tile_type(vertex)
		if height_noise and biome_noise:
			var biome_val = get_biome_value(Vector2(vertex.x, vertex.z))
			var h = get_height(Vector2(vertex.x, vertex.z))
			var tile_location = pos_to_tile(vertex*0.9)
			var tile_index = tile_location.x + tile_location.y * height
			if (biome_val > mountain_height):
				cells[tile_index] = terrain_types.mountain
			elif (biome_val > land_height):
				cells[tile_index] = terrain_types.land
			else:
				cells[tile_index] = terrain_types.water
			vertex.y += biome_value_to_height(h) + get_height(Vector2(vertex.x, vertex.z))
			
		normal_array[i] = get_normal(Vector2(vertex.x, vertex.z))
		vertex_array[i] = vertex
	
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	terrain.mesh = array_mesh

func pos_to_tile(pos: Vector3) -> Vector2i:
	var relative =  pos - global_position 
	relative.x = relative.x+(width*cell_size)/2
	relative.z = relative.z+(height*cell_size)/2
	var x = int(floor(relative.x/cell_size))
	var y = int(floor(relative.z/cell_size))
	x = clampi(x, 0, width-1)
	y = clampi(y, 0, height-1)

	return Vector2i(x, y)
	
func world_to_map_pos(pos: Vector3) -> Vector2:
	var relative =  pos - global_position 
	relative.x = relative.x+(width*cell_size)/2
	relative.z = relative.z+(height*cell_size)/2
	return Vector2((relative.x/cell_size), (relative.z/cell_size))
	
func get_biome_value(pos: Vector2):
	return (1.0+biome_noise.get_noise_2d(pos.x*noise_resolution/8.0, pos.y*noise_resolution/8.0))/2.0
	
func get_height(pos: Vector2):
	return (1.0+biome_noise.get_noise_2d(pos.x*noise_resolution, pos.y*noise_resolution))/2.0
	
func get_normal(pos: Vector2) -> Vector3:
	const epsilon = 0.2
	var v1 = Vector3(pos.x, get_biome_value(pos + Vector2(-epsilon, -epsilon/2.0)), pos.y)
	var v2 = Vector3(pos.x, get_biome_value(pos + Vector2(epsilon, -epsilon/2.0)), pos.y)
	var v3 = Vector3(pos.x, get_biome_value(pos + Vector2(0.0, epsilon/2.0)), pos.y)
	var result = Vector3(0.0, 1.0, 0.0)
	var a = v1-v2
	var b = v1-v3
	result.x = a.y * b.z - a.z * b.y
	result.y = a.z * b.x - a.x * b.z
	result.z = a.x * b.y - a.y * b.x
	if result.y < 0:
		result *= -1.0
	return result

func pos_to_tile_type(pos: Vector3) -> terrain_types:
	var relative =  pos - global_position 
	relative.x = relative.x+(width*cell_size)/2
	relative.z = relative.z+(height*cell_size)/2
	var x = int(floor(relative.x/cell_size))
	var y = int(floor(relative.z/cell_size))
	x = clampi(x, 0, width-1)
	y = clampi(y, 0, height-1)
	return cells[x + y*width]

func get_tile_index(x: int, y: int):
	if x < 0 or x >= width or y < 0 or y >= height:
		return -1
	return cells[x+y*width]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	biome_noise.seed = randi()
	height_noise.seed = randi()
	generate_grid()
	update_mesh()

func generate_grid():
	cells.resize(width*height)
	


# Inverse of pos_to_tile
# Example to convert the map position a tile a creep is on to a world position 
# ActualPos = 0, 0
# TilePos = 4, 4
# CellSize = 8
#
# tile_pos * cell_size = result (32, 32)
#
# result * 2 = result (64, 64)
#
# result - (width * cell_size) = result (0, 0)

## Translates a tile's position in the map to a world position.
## This method will only return positions that are multiples of cell_size
## so there can be substantial loss in precision.
func tile_to_world_position(tile: Vector2i) -> Vector3:
	# NOTE: This probably wont work if we ever need to get the hight of a tile :/
	var result: Vector3 = Vector3(tile.x, 0, tile.y) * cell_size # Expand to local map position
	result *= 2 # ?
	result -= Vector3(width * cell_size, 0, height * cell_size) # Back into world position
	
	return result
