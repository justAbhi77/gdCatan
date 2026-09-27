extends Node3D

@export var gen_iteration_time: float = 0.1

@export var board_config : boardConfig
@export var snap_grid : Vector3
@export var tile_div : Vector2
@export var grid_center_location : Vector3
@export var grid_bottom_left_location : Vector3
@export var board_seed : int
@export var shuffled_tile_types: Array[gdCatanTypes.EHexTileType]
@export var shuffled_dice_numbers: Array[int]

@export var spawned_tiles: Dictionary[Vector2i, BoardTile]

func _ready():
	initialize_board()

	if multiplayer.is_server():
		start_board_gen.rpc(randi())

func initialize_board():
	var tile_size: Vector3 = board_config.grid_tile_size
	
	snap_grid = gdCatanMathHelper.calculate_snap_grid(tile_size)
	tile_div = gdCatanMathHelper.calculateTileDiv(tile_size)

	grid_center_location = position.snapped(tile_size)
	var tile_count: Vector2i = board_config.get_grid_tile_count()
	grid_bottom_left_location = gdCatanMathHelper.calculate_grid_bottom_left(grid_center_location, tile_count, tile_size)

@rpc("authority", "call_local", "reliable")
func start_board_gen(in_seed: int):
	board_seed = in_seed
	var grid_size: Vector2i = board_config.get_grid_tile_count()
	var shuffled_data: gdCatanTypes.ShuffledData = board_config.get_shuffled_tiles(in_seed)
	shuffled_tile_types = shuffled_data.tile_types
	shuffled_dice_numbers = shuffled_data.shuffled_dice_numbers 

	var temp_index: int = 0
	for x in range(grid_size.x):
		var bShouldNotSubtract: bool = int((grid_size.x + 1) / 2.0) % 2 == 0

		var Bounds: int = abs((grid_size.x - (x * 2 + 1)) / 2.0)

		var OutLowerBound: int = (Bounds + 1) if bShouldNotSubtract else Bounds

		var RowOffset: int = Bounds if (Bounds % 2 == 0) else (Bounds - 1)

		var EndY: int = grid_size.y * 2 - 1 - RowOffset;

		var OutUpperBound: int = EndY if bShouldNotSubtract else EndY - 1;
		for y in range(OutLowerBound, OutUpperBound + 1, 2):
			var tile_index: Vector2i = gdCatanMathHelper.make_tile_index(x, y)
			var tile_size: Vector3 = board_config.grid_tile_size
			
			var tile_scale: Vector3 = board_config.tile_mesh_size / tile_size
			var settlement_scale: Vector3 = board_config.settlement_mesh_size / tile_size;
			
			var tile_location := gdCatanMathHelper.tile_index_to_world(tile_index, grid_bottom_left_location, tile_size)
			var tile: BoardTile = spawned_tiles.get_or_add(tile_index)
			
			if !tile:
				tile = board_config.HexTileClass.instantiate() as BoardTile
				spawned_tiles[tile_index] = tile
				var temp: int = temp_index % shuffled_tile_types.size()
				tile.tile_index = tile_index
				tile.tile_type = shuffled_tile_types[temp]
				tile.tile_color = board_config.tile_type_color[tile.tile_type]
				var tile_name := "%s %s" % [gdCatanTypes.EHexTileType.keys()[tile.tile_type], tile.tile_index]
				tile.set_name(tile_name)
				add_child(tile)
				tile.position = tile_location
				tile.scale = tile_scale

				temp_index += 1

			await get_tree().create_timer(gen_iteration_time).timeout

			var vertices: Array[Vector2i] = gdCatanMathHelper.get_hexagon_vertices(tile_index)
			for vertex_num in range(vertices.size()):
				var vertex: Vector2i = vertices[vertex_num]
				var vertex_world := gdCatanMathHelper.tile_index_to_world(vertex, grid_bottom_left_location, tile_size)
				vertex_world.z = tile_size.z * 1.1
				var settlement: BoardTile = spawned_tiles.get_or_add(vertex)
				
				if !settlement:
					settlement = board_config.HexTileClass.instantiate() as BoardTile
					spawned_tiles[vertex] = settlement
					settlement.tile_index = vertex
					settlement.tile_type = gdCatanTypes.EHexTileType.Settlement
					settlement.tile_color = Color.WHITE

					var settlement_name := "%s %s" % [gdCatanTypes.EHexTileType.keys()[settlement.tile_type], settlement.tile_index]
					settlement.set_name(settlement_name)

					tile.add_child(settlement)

					settlement.global_position = vertex_world
					settlement.rotation = Vector3.ZERO
					settlement.scale = settlement_scale

				await get_tree().create_timer(gen_iteration_time).timeout

				var next_index: int = (vertex_num + 1) % vertices.size()
				var next_vertex: Vector2i = vertices[next_index]

				var next_world: Vector3 = gdCatanMathHelper.tile_index_to_world(next_vertex, grid_bottom_left_location, tile_size)
				next_world.z = tile_size.z * 1.1

				var mid_point: Vector2i = (vertex + next_vertex) / 2.0;
				var mid_point_world: Vector3 = (vertex_world + next_world) * 0.5;
				
				var road: BoardTile = spawned_tiles.get_or_add(mid_point)
				if road:
					continue
				
				var road_length: float = (vertex_world - next_world).length()
				var road_rotation := Basis.looking_at(next_world - vertex_world, Vector3.UP).get_euler()

				road = board_config.HexTileClass.instantiate() as BoardTile
				spawned_tiles[mid_point] = road
				road.tile_index = mid_point
				road.tile_type = gdCatanTypes.EHexTileType.Road
				road.tile_color = Color.LIGHT_GRAY

				var road_name := "%s %s" % [gdCatanTypes.EHexTileType.keys()[road.tile_type], road.tile_index]
				road.set_name(road_name)

				tile.add_child(road)

				road.tile_mesh.mesh = BoxMesh.new()
				road.global_position = mid_point_world
				road.global_rotation = road_rotation
				road.scale = Vector3(0.1, board_config.RoadMeshSizeY, road_length)
