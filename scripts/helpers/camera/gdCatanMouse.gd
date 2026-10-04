
class_name gdCatanMouse
extends Node3D

@export var Board: gdCatanBoardGen
@export var Camera: gdCatanCamera
@export var ui: gdCatanWorldUi


var last_mouse_pos: Vector2
var last_hover_result: Vector2i

var last_hovered_tile: gdCatanBoardTile

func _physics_process(_delta: float)-> void:
	# get mouse pos on screen 
	var mouse_pos := get_viewport().get_mouse_position()

	if(last_mouse_pos.is_equal_approx(mouse_pos)):
		return

	var intersection := get_mouse_grid_intersection(mouse_pos)
	update_hovered_tile(intersection)
	
	last_mouse_pos = mouse_pos
	
func get_mouse_grid_intersection(mouse_pos: Vector2) -> Vector3:
	if Camera == null or Camera.Camera == null:
		return Vector3.ZERO

	# get mouse pos in world space and direction from camera to mouse
	var world_origin := Camera.Camera.project_ray_origin(mouse_pos)
	var world_direction := Camera.Camera.project_ray_normal(mouse_pos)

	# GridCenterLocation equivalent
	var plane := Plane(Board.transform.basis.y, Board.grid_center_location.y)

	# Ray/plane intersection
	var intersection: Vector3 = plane.intersects_ray(world_origin, world_direction)

	return intersection

func update_hovered_tile(intersection: Vector3) -> void:
	var hover_result := gdCatanMathHelper.getMouseIntersectionResult(intersection, Board.grid_bottom_left_location, Board.tile_div)

	var tile: gdCatanBoardTile = Board.spawned_tiles.get(hover_result.closest_index)

	if tile:
		ui.label.text = "Hovered Tile: " + str(hover_result.closest_index) + " | Type: " + gdCatanTypes.EHexTileType.keys()[tile.tile_type]
	else:
		ui.label.text = "Hovered Tile: None"

	ui.label2.text = "Grid Local: " + str(hover_result.grid_local)
	ui.label3.text = "Tile Index (Continuous): " + str(hover_result.tile_index_continuous)
	ui.label4.text = "Unsnapped: " + str(hover_result.unsnapped)
	ui.label5.text = "Snapped Tile Index: " + str(hover_result.snapped_tile_index)

	if hover_result.closest_index == last_hover_result:
		return

	# Remove highlight from previous tile
	if last_hovered_tile:
		last_hovered_tile.toggle_highlight(false)
		last_hovered_tile = null

	# Highlight new tile
	if tile:
		tile.toggle_highlight(true)
		last_hovered_tile = tile

	last_hover_result = hover_result.closest_index
