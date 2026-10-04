
class_name gdCatanBoardTile
extends Node3D

@onready var tile_mesh: MeshInstance3D = $Mesh
@onready var tile_label: Label3D = $Label3D

@export var tile_index: Vector2i
@export var tile_type: gdCatanTypes.EHexTileType
@export var tile_color: Color

func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tile_color
	tile_mesh.material_override = mat
	
	tile_label.text = str(tile_index)


func toggle_highlight(highlight: bool) -> void:
	if highlight:
		tile_mesh.material_override.albedo_color = Color(1, 1, 0, 1) # Yellow highlight
	else:
		tile_mesh.material_override.albedo_color = tile_color # Reset to original color
