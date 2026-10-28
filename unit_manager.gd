extends Node
class_name UnitManager

var units: Array[Node3D]

func add_unit(newUnit:Node3D) -> void:
	if not units.has(newUnit):
		print("Added unit: ", newUnit.name)
		units.append(newUnit)

func remove_unit(unit: Node3D) -> void:
	units.erase(unit)

func get_units() -> Array[Node3D]:
	return units

func get_overlapping_units(unit: Node3D) -> Array[Node3D]:
	var overlapping_units: Array[Node3D]
	for other in units:
		if other == unit:
			continue
		var dist = unit.global_position.distance_to(other.global_position)
		var combined_radius = unit.cohesionSize + other.cohesionSize
		if dist < combined_radius:
			overlapping_units.append(other)
	return overlapping_units


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
