@icon("camera_player_3d.svg")
class_name CameraPlayer3D
extends CharacterBody3D
## The player maintains their Y level while moving and looking.
## They will go up and down using the upwards and downwards input actions.

# TODO: Use node stack (components) instead?
# TODO: Scrolling in and out moves camera or only changes fov?

@export_category("Options")
@export_subgroup("Camera")
# TBD: This camera variable is probably stupid.
# Theres no reason to not just hard code it as the child camera.
@export var camera: Camera3D = null
@export var sensitivity: Vector2 = Vector2.ONE
@export var invert_mouse_y: bool = false
@export_subgroup("Body")
@export var speed_modifier: float = 1.0
@export var friction: float = 0.5
# NOTE: Don't forget to negate gravity!
@export var gravity: float = -0
@export var terminal_velocity: Vector3 = Vector3.ONE
@export_category("Debug")
@export var print_velocity: bool = false

# TODO: I don't like having these global :\
var move_vector: Vector2 = Vector2.ZERO
var vertical_movement: float = 0.0


func _input(event: InputEvent) -> void:
	move_vector = Input.get_vector("camera_player_3d_move_leftwards", "camera_player_3d_move_rightwards", "camera_player_3d_move_forwards", "camera_player_3d_move_backwards")
	vertical_movement = Input.get_action_strength("camera_player_3d_move_upwards") - Input.get_action_strength("camera_player_3d_move_downwards")
	
	if Input.get_action_strength("camera_player_3d_look"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		if event is InputEventMouseMotion:
			look((event as InputEventMouseMotion).screen_relative)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(_delta: float) -> void:
	move(move_vector)


func move(vector: Vector2) -> void:
	# APPLY THE BASIS FIRST!!!!!
	velocity += basis * Vector3(vector.x, vertical_movement, vector.y) * speed_modifier
	
	velocity = velocity.clamp(-terminal_velocity, terminal_velocity)
	
	if print_velocity:
		print_debug("Velocity is: ", velocity)
	
	var _body_collided: bool = move_and_slide()
	
	# TODO: There is a better way of doing this...
	velocity.x = move_toward(velocity.x, 0, friction)
	velocity.z = move_toward(velocity.z, 0, friction)
	
	# Don't use the evil gravity function. WE DONT WANT GRAVITY >:(
	#velocity.y = move_toward(velocity.y, terminal_velocity.y, gravity)
	velocity.y = 0.0


func look(mouse_delta: Vector2) -> void:
	# Don't even try if camera is invalid
	if not camera:
		return
	
	rotate_y(deg_to_rad(-mouse_delta.x) * sensitivity.x)
	# Camera rotates on the y axis if player tries to look up/down while at up/down look limit
	# Remember the y rotation so we can reset to it before the x rotation messes it up 
	var hold_y: float = rotation.y
	
	if invert_mouse_y:
		camera.rotate_x(deg_to_rad(mouse_delta.y) * -1 * sensitivity.y)
	else:
		camera.rotate_x(deg_to_rad(mouse_delta.y) * sensitivity.y)
		
	camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, -90.0, 90.0)
	rotation.y = hold_y
	
	rotation.z = 0.0
