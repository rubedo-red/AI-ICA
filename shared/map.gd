extends Node

enum terrain_types { land, water, mountain }

var width : int = 10
var height : int = 10
var cells : PackedByteArray = [0]
var cell_size: float = 2.0

func transform_to_tile(transform: Transform3D):
	var position = transform.basis.x
	var relative = position - transform.basis.x
	var x = int(floor(relative.x/(width*cell_size)-((width/2)*cell_size)))
	var y = int(floor(relative.y/(height*cell_size)-((height/2)*cell_size)))
	return x + y*width

func generate_terrain():
	for i in width:
		for j in height:
			var tile = MeshInstance3D.new()
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
	generate_terrain()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resize(width, height)
	for i in width:
		cells[i] = 1
		cells[width*(height-1)+i] = 2
	generate_terrain()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
