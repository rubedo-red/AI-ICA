@icon("res://ui/creep_picker/creep_base_node_icon.png")
class_name CreepBase
extends VBoxContainer

signal im_selected(id: int)

# @TODO YUCKY YUCKY I'd like this to be seperated into TextureRect and Label
# But each subclass has to add a TextureRect and Label :(((((
@export var icon: Texture2D = null
@export var label_text: String = "Creep Name Here"

## Creeps get given an ID by the Creep Picker. -1 indicates a lack of ID.
var id: int = -1


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		@warning_ignore("unsafe_property_access")
		if event.button_index == MOUSE_BUTTON_LEFT:
			print_debug("I (creep no. ", id, ") was pressed!")
			im_selected.emit(id)
