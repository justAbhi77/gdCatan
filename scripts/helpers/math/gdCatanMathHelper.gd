
class_name gdCatanMathHelper

static var ONE_MOD_SIX: float = 1.0 / 6.0
static var POINT_ONE_TWO_FIVE: float = 0.125
static var POINT_TWO_FIVE: float = 0.25

static func calculate_snap_grid(tileSize : Vector3) -> Vector3:
	return Vector3(tileSize.x * POINT_ONE_TWO_FIVE, tileSize.y, tileSize.z * POINT_TWO_FIVE * ONE_MOD_SIX)

static func calculateTileDiv(tileSize : Vector3) -> Vector2:
	return Vector2(tileSize.x * POINT_ONE_TWO_FIVE, tileSize.z)

static func snap_vector_to_vector(vectorToSnap : Vector3, gridSize : Vector3) -> Vector3:
	return vectorToSnap.snapped(gridSize)

static func calculate_grid_bottom_left(center: Vector3, grid_size: Vector2i, tile_size: Vector3) -> Vector3:
	@warning_ignore("integer_division")
	var grid_offset: Vector2i = grid_size / Vector2i(3, 3)
	var snapped_tile_count: Vector3 = tile_size * Vector3(grid_offset.x, 0.0, grid_offset.y)

	return center - snapped_tile_count.snapped(tile_size)

static func make_tile_index(x: int, y: int) -> Vector2i:
	return Vector2i(x * 6, y * 6)

static func tile_index_to_world(tile_index: Vector2i, tile_type: gdCatanTypes.EHexTileType,grid_bottom_left: Vector3, tile_size: Vector3) -> Vector3:
	var tile_size_world := tile_size_to_world(tile_size)

	var tile_size_y :=  0.0
	if tile_type == gdCatanTypes.EHexTileType.Settlement or tile_type == gdCatanTypes.EHexTileType.Road:
		tile_size_y = tile_size.y * 1.1

	return grid_bottom_left + Vector3(tile_index.x * tile_size_world.x, tile_size_y, tile_index.y * tile_size_world.y)

static func tile_size_to_world(tile_size: Vector3) -> Vector2:
	var tile_x_075: float = tile_size.x * POINT_ONE_TWO_FIVE
	var tile_z_05: float  = tile_size.z * 0.5 * ONE_MOD_SIX
	
	return Vector2(tile_x_075, tile_z_05)

static func get_hexagon_vertices(center: Vector2i) -> Array[Vector2i]:
	return [
		center + Vector2i(4, 0),
		center + Vector2i(2, 6),
		center + Vector2i(-2, 6),
		center + Vector2i(-4, 0),
		center + Vector2i(-2, -6),
		center + Vector2i(2, -6),
		]

static func get_hexagon_edges(center: Vector2i) -> Array[Vector2i]:
	return [
		center + Vector2i(3, 3),
		center + Vector2i(0, 6),
		center + Vector2i(-3, 3),
		center + Vector2i(-3, -3),
		center + Vector2i(0, -6),
		center + Vector2i(3, -3),
		]
