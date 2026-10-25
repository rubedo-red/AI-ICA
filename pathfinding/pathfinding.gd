extends Node3D


# TODO: Map has no static type in this early version!!! Fixed in later version!!
# I used Node3D otherwise Godot thinks I want to export something that only accepts NULL
# I also ignored unsafe_method_access warnings BECAUSE WE NEED A TYPE FOR THE MAP !!!!!!!!!!!!!!!!!
@export var map: Node3D = null
@export var creep: CharacterBody3D = null

func _on_button_button_up() -> void:
	if map == null:
		push_error("Please supply a map in the @export map variable!")
		return
	if creep == null:
		push_error("Please supply a creep so we can send it to a destination.")
	
	match $VBoxContainer/HBoxContainer/OptionButton.get_index():
		0:
			pass
		1:
			breadth_first_search()
		2:
			pass
		3:
			pass
		_:
			push_error("Invalid index")


func depth_first_search() -> void:
	pass


func breadth_first_search(allow_diagonal: bool = false) -> void:
	if allow_diagonal:
		push_warning("allow_diagonal not implemented!")
	
	@warning_ignore("unsafe_method_access")
	var starting_tile: int = map.transform_to_tile(creep.get_transform())
	
	print_debug(starting_tile)
	
	pass
