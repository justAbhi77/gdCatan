extends Node3D

@onready var SpringArm: SpringArm3D = $SpringArm3D
@onready var Camera: Camera3D = $SpringArm3D/Camera3D

@export_category("Movement")
@export var move_input_mul: float = 20.0
@export var move_speed: float = 5.0

@export_category("Rotation")
@export var rotation_input_mul: float = 2.0
@export var rotation_speed: float = 45.0

@export_category("Zoom")
@export var zoom_speed: float = 2.0
@export var zoom_smooth_speed: float = 10.0
@export var min_zoom: float = 2.0
@export var max_zoom: float = 15.0

var zoom_desired: float
var location_desired: Vector3
var rotation_desired: Vector3

var scroll_axis_value: float = 0.0

var forward_axis_value: float = 0.0
var right_axis_value: float = 0.0
var rotation_axis_value: float = 0.0

var invert_y_axis: bool = false


func _ready() -> void:
	location_desired = global_position
	zoom_desired = SpringArm.spring_length
	rotation_desired = rotation


func _process(delta: float) -> void:
	process_movement(delta)
	handle_rotation(delta)


func _physics_process(delta: float) -> void:
	process_zoom(delta)
	
	var movement_alpha := 1.0 - exp(-move_speed * delta)
	global_position = global_position.lerp(location_desired, movement_alpha)

	var rotation_alpha := 1.0 - exp(-rotation_speed * delta)
	rotation.y = lerp_angle(rotation.y, rotation_desired.y, rotation_alpha)


func process_movement(delta: float) -> void:
	forward_axis_value = Input.get_axis("move_backward", "move_forward")
	right_axis_value = Input.get_axis("move_left", "move_right")

	# local forward direction is -Z.
	var forward := -global_transform.basis.z
	var right := global_transform.basis.x

	var movement := (forward * forward_axis_value + right * right_axis_value)

	# Prevent diagonal movement from being faster.
	movement = movement.normalized()

	location_desired += movement * move_input_mul * delta


func handle_rotation(delta: float) -> void:
	var input := Input.get_axis("rotate_left", "rotate_right")
	
	if input > 0:
		rotation_axis_value = 1
	elif input < 0:
		rotation_axis_value = -1
	else:
		rotation_axis_value = 0

	rotation_desired.y += rotation_axis_value * rotation_input_mul * delta


func process_zoom(delta: float) -> void:
	if scroll_axis_value != 0.0:
		zoom_desired -= scroll_axis_value * zoom_speed
		zoom_desired = clamp(zoom_desired, min_zoom, max_zoom)

		scroll_axis_value = 0.0

	# Frame-rate independent smoothing.
	var zoom_alpha := 1.0 - exp(-zoom_smooth_speed * delta)

	SpringArm.spring_length = lerp(SpringArm.spring_length, zoom_desired, zoom_alpha)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					scroll_axis_value = 1.0

				MOUSE_BUTTON_WHEEL_DOWN:
					scroll_axis_value = -1.0
