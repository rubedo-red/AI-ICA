extends Control

@onready var rand_button : Button = $Sliders/VSeparator/seed_randomize
@onready var seed_input : LineEdit = $Sliders/VSeparator/seed_input
@onready var width_slider: HSlider = $Sliders/width_slider
@onready var height_slider: HSlider = $Sliders/height_slider
@onready var water_slider: HSlider = $Sliders/pct_water_slider
@onready var mountain_slider: HSlider = $Sliders/pct_mnt_slider
@onready var generate_button: Button = $Button
@onready var map : Map = $Map

func _ready() -> void:
	rand_button.button_down.connect(randomize_seed)
	seed_input.text = str(map.seed)
	seed_input.text_submitted.connect(change_seed)
	width_slider.drag_ended.connect(change_size)
	height_slider.drag_ended.connect(change_size)
	water_slider.drag_ended.connect(change_water)
	mountain_slider.drag_ended.connect(change_mountain)
	generate_button.button_down.connect(generate_world)
	
func generate_world() -> void:
	var gamescene = preload("res://main_scene.tscn").instantiate()
	var gamemap : Map = gamescene.get_node("Map")
	gamemap.seed = seed_input.text.to_int()
	gamemap.width = width_slider.value
	gamemap.height = height_slider.value
	gamemap.land_height = water_slider.value
	gamemap.mountain_height = 1.0-mountain_slider.value
	var tree := get_tree()
	var current := tree.current_scene
	tree.root.add_child(gamescene)
	tree.current_scene = gamescene
	current.queue_free()
	
func change_water(changed: bool) -> void:
	if changed:
		mountain_slider.value = 1.0-max(water_slider.value, 1.0-mountain_slider.value)
		map.mountain_height = (1.0-mountain_slider.value)
		map.land_height = water_slider.value
		map.regenerate_map()
	
func change_mountain(changed: bool) -> void:
	if changed:
		water_slider.value = min(water_slider.value, 1-mountain_slider.value)
		map.mountain_height = (1.0-mountain_slider.value)
		map.land_height = water_slider.value
		map.regenerate_map()
	
func change_seed(new_seed: String) -> void:
	map.seed = new_seed.to_int()
	map.regenerate_map()
	
func change_size(changed: bool) -> void:
	if changed:
		map.width = width_slider.value
		map.height = height_slider.value
		map.regenerate_map()

func randomize_seed() -> void:
	map.seed = randi()
	seed_input.text = str(map.seed)
	map.regenerate_map()

func _process(delta: float) -> void:
	pass
