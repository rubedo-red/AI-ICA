extends CharacterBody3D


# Inverted - Move up to look down. Normal - Move up to look up (Like Apple natural scrolling)
enum Mouse_Y_Modifier { INVERTED = -1, NORMAL = 1 }


@export var speed: float = 1.0
@export var mouse_sensitivity: Vector2 = Vector2.ONE
# Cleanest way to invert mouse_delta_y? Probably!
@export var mouse_y_modifier: Mouse_Y_Modifier = Mouse_Y_Modifier.NORMAL
@export_category("Debug")
@export var print_rotation: bool = false
@export var print_mouse_delta: bool = false
@export var print_velocity: bool = false

var tmp_velocity: Vector2 = Vector2.ZERO


func _input(event: InputEvent) -> void:
	tmp_velocity = Input.get_vector("player_move_left",
	"player_move_right", "player_move_forwards", "player_move_backwards")
	
	if Input.is_action_pressed("player_alt_move") and event is InputEventMouseMotion:
		# Get mouse delta
		@warning_ignore("unsafe_property_access")
		var mouse_delta: Vector2 = event.screen_relative
		
		# Use mouse delta to rotate
		# @TODO: Better implentation use objects basis or something maybe . its a scary matrix ...
		rotate_y(deg_to_rad(mouse_delta.x * mouse_sensitivity.x))
		rotate_x(deg_to_rad(mouse_delta.y * mouse_y_modifier * mouse_sensitivity.y))
		# We don't want any roll
		rotation.z = 0.0
		
		# @TODO Make sure the camera cannot flip
		
		
		if print_mouse_delta:
			print_debug("Mouse delta is:", mouse_delta)
		


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	move(tmp_velocity)
	
	# Reset velocity
	velocity = Vector3.ZERO


func move(new_velocity: Vector2) -> void:
	new_velocity *= speed
	velocity += Vector3(new_velocity.x, 0.0, new_velocity.y)
	
	if print_velocity:
		print_debug("Velocity is: ", velocity)
	
	@warning_ignore("return_value_discarded")
	move_and_slide()
