extends CanvasLayer

@export var creep_picker: Control = null

var valid: bool = false


func _ready() -> void:
	if creep_picker == null:
		push_error("No Creep Picker specified! WAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
