extends Control


@export var creep_list: Array[CreepBase] = []

var selected_creep_index: int = -1


func _ready() -> void:
	# Give creeps an id
	var creep_id: int = 0
	for creep: CreepBase in creep_list:
		creep.id = creep_id
		creep_id += 1
		@warning_ignore("return_value_discarded")
		creep.im_selected.connect(creep_selected)


func creep_selected(id: int) -> void:
	print_debug("Creep ", id, " was selected!")
