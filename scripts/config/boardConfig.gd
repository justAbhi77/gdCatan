
class_name boardConfig
extends Resource

@export var hexagon_grid_size: int = 3
@export var grid_tile_size: Vector3 = Vector3(1.15, 1, 0.1)
@export var tile_mesh_size: Vector3 = Vector3(1.15, 1, 0.1)
@export var settlement_mesh_size: Vector3 = Vector3(0.25, 0.25, 0.1)
@export var RoadMeshSizeY: float = 0.05
@export var HexTileClass: PackedScene
@export var tileTypeDistribution: Dictionary[gdCatanTypes.EHexTileType, int] = {
	gdCatanTypes.EHexTileType.Desert: 1,
	gdCatanTypes.EHexTileType.Brick: 3,
	gdCatanTypes.EHexTileType.Forest: 4,
	gdCatanTypes.EHexTileType.Mountain: 3,
	gdCatanTypes.EHexTileType.Farm: 4,
	gdCatanTypes.EHexTileType.Grassland: 4,
}
@export var tile_type_color: Dictionary[gdCatanTypes.EHexTileType, Color] = {
	gdCatanTypes.EHexTileType.Desert: Color(0.85, 0.80, 0.55, 1.0),  # sand
	gdCatanTypes.EHexTileType.Brick: Color(0.72, 0.25, 0.20, 1.0),  # clay
	gdCatanTypes.EHexTileType.Forest: Color(0.10, 0.45, 0.15, 1.0),  # wood
	gdCatanTypes.EHexTileType.Mountain: Color(0.45, 0.45, 0.48, 1.0),  # ore
	gdCatanTypes.EHexTileType.Farm: Color(0.95, 0.85, 0.30, 1.0),  # wheat
	gdCatanTypes.EHexTileType.Grassland: Color(0.35, 0.70, 0.30, 1.0),  # sheep
}

# Functions
func get_grid_tile_count() -> Vector2i :
	var tile_size: int = hexagon_grid_size * 2 - 1;
	return Vector2i(tile_size, tile_size)

func get_shuffled_tiles(in_seed: int) -> gdCatanTypes.ShuffledData:
	var shuffled_data: gdCatanTypes.ShuffledData = gdCatanTypes.ShuffledData.new()

	for key in tileTypeDistribution:
		for i in range(tileTypeDistribution[key]):
			shuffled_data.tile_types.append(key)

	# Standard Catan dice number distribution (excluding desert)
	var dice_numbers : Array[int] = [
		2,
		3, 3,
		4, 4,
		5, 5,
		6, 6,
		8, 8,
		9, 9,
		10, 10,
		11, 11,
		12
	]

	gdCatanHelper.seeded_shuffle(shuffled_data.tile_types, in_seed)
	gdCatanHelper.seeded_shuffle(dice_numbers, in_seed + 1)
	
	var diceIndex: int = 0
	
	for tileType in shuffled_data.tile_types:
		if tileType == gdCatanTypes.EHexTileType.Desert:
			shuffled_data.shuffled_dice_numbers.append(-1);		    
		else:
			shuffled_data.shuffled_dice_numbers.append(dice_numbers[diceIndex])
			diceIndex += 1
	
	return shuffled_data
