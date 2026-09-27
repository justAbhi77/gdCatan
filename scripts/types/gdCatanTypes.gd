
class_name gdCatanTypes

enum EHexSnapType { None, Tile, Edge, Vertex }

enum EHexTileType { None, Desert, Brick, Forest, Mountain, Farm, Grassland, Water, Settlement, Road }

class ShuffledData:
	var tile_types: Array[EHexTileType]
	var shuffled_dice_numbers: Array[int]