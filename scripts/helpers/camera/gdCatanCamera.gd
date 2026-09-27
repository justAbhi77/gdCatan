
extends Node3D

@export_category("Movement")
@export var move_speed: float = 10.0

@export_category("Rotation")
@export var rotation_speed: float = 2.0

@export_category("Zoom")
@export var zoom_speed: float = 10.0
@export var min_zoom: float = 5.0
@export var max_zoom: float = 30.0

var current_zoom: float

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	handle_movement(delta)
	handle_rotation(delta)
	handle_zoom(delta)


func handle_movement(delta: float) -> void:
	var direction := Vector3.ZERO

	if Input.is_key_pressed(KEY_W):
		direction.z -= 1.0

	if Input.is_key_pressed(KEY_S):
		direction.z += 1.0

	if Input.is_key_pressed(KEY_A):
		direction.x -= 1.0

	if Input.is_key_pressed(KEY_D):
		direction.x += 1.0

	if direction.length() > 0.0:
		direction = direction.normalized()

		global_position += direction * move_speed * delta


func handle_rotation(delta: float) -> void:
	if Input.is_key_pressed(KEY_Q):
		rotation.y += rotation_speed * delta

	if Input.is_key_pressed(KEY_E):
		rotation.y -= rotation_speed * delta


func handle_zoom(delta: float) -> void:
	if Input.is_key_pressed(KEY_Z):
		current_zoom -= zoom_speed * delta

	if Input.is_key_pressed(KEY_X):
		current_zoom += zoom_speed * delta

	current_zoom = clamp(current_zoom, min_zoom, max_zoom)

	# phantom_camera.follow_distance = current_zoom
