
class_name gdCatanBoardTile
extends Node3D

@onready var tile_mesh: MeshInstance3D = $tileMesh

@export var tile_index: Vector2i
@export var tile_type: gdCatanTypes.EHexTileType
@export var tile_color: Color

func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tile_color
	tile_mesh.material_override = mat