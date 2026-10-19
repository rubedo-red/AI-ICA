extends Node3D

enum terrain_types { land, water, mountain }

@export var width : int = 10
@export var height : int = 10
var cells : PackedByteArray = [0]
@export var cell_size: float = 2.0

func pos_to_tile(pos: Vector3):
	var relative =  pos - global_position 
	relative.x = relative.x+(width*cell_size)/2
	relative.z = relative.z+(height*cell_size)/2
	var x = int(floor(relative.x/cell_size))
	var y = int(floor(relative.z/cell_size))

	return [x, y]

func get_tile_index(x: int, y: int):
	if x < 0 or x >= width or y < 0 or y >= height:
		return -1
	return cells[x+y*width]

func create_terrain():
	for i in width:
		for j in height:
			var tile = MeshInstance3D.new()
			tile.name = "tile-"+str(i)+"_"+str(j)
			self.add_child(tile)
			var plane = PlaneMesh.new()
			plane.size.x = cell_size
			plane.size.y = cell_size
			tile.mesh = plane
			
			var material = StandardMaterial3D.new()
			match cells[i+j*width]:
				terrain_types.land: 
					material.albedo_color = Color(0.3,0.7,0.1)
				terrain_types.water:
					material.albedo_color = Color(0.2,0.2,0.7)
				terrain_types.mountain:
					material.albedo_color = Color(0.7, 0.7, 0.7)
			#material.emission_intensity = 0
			tile.mesh.surface_set_material(0, material) 
			tile.position = Vector3((i-width/2)*cell_size, 0, (j-height/2)*cell_size)

func resize(w: int, h: int) -> void:
	width = w
	height = h
	cells.resize(w*h)
	cells.fill(0)

@export var land_weight = 6;
@export var water_weight = 4;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resize(width, height)
	for i in width*height:
		cells[i] = min(randi()%(land_weight+water_weight)/land_weight, 1)
	for i in 100:
		iterate_automata()
	create_terrain()
	
	
func get_neighbour_count(index: int):
	var x = index%height
	var y: int = index/width
	var count = 0
	for n in range(-1, 2):
		for m in range(-1, 2):
			var checkx = m+x 
			var checky = n+y
			if (checkx>=0 and checkx<width and checky>=0 and checky<height):
				count += min(cells[checkx+checky*width],1)
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
