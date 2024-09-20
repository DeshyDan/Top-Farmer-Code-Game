extends TileMap
# Class contains the logic for creating a visual representing of a FarmModel
# It provides functionality like setting the layers in which FarmItems should be 
# placed as well as their textures.
# It also provides functions for obtaining data about a tile

const PLANT_LAYER = 0
const SOIL_LAYER = 1
const ROCK_LAYER = 2
const SOIL_TERRAIN = 0
const WATER_TERRAIN = 1
const TRANSLUCENT_LAYER = 3

func fill_with_dirt(width: int, height: int):
	var path = make_rect_path(width, height)
	
	set_cells_terrain_connect(SOIL_LAYER, path, 0, SOIL_TERRAIN)
	clear_layer(ROCK_LAYER)
	clear_layer(TRANSLUCENT_LAYER)

func make_rect_path(width: int, height: int):
	var map = []
	for x in range(width):
		for y in range(height):
			map.append(Vector2i(x, y))

	return map

func get_soil_data(coords: Vector2i):
	return get_cell_tile_data(SOIL_LAYER, coords)

func set_plant(coords: Vector2i, farm_item: FarmItem):
	var atlas_x = min(farm_item.get_age(), 3)
	set_cell(PLANT_LAYER, coords, farm_item.get_source_id(), Vector2i(atlas_x, 0))

func erase_plant(coords: Vector2i):
	set_cell(PLANT_LAYER, coords, -1)

func clear_plants():
	clear_layer(PLANT_LAYER)

func set_rock_tile(coords: Vector2i, farm_item: FarmItem):
	var layer = TRANSLUCENT_LAYER if farm_item.is_translucent() else ROCK_LAYER
	set_cell(layer, coords, farm_item.get_source_id(), Vector2i.ZERO)

func set_water_tile(coords: Vector2i, farm_item: FarmItem):
	set_cells_terrain_connect(
						TRANSLUCENT_LAYER,
						[coords],
						0,
						WATER_TERRAIN,
						false
					)
	var layer = TRANSLUCENT_LAYER if farm_item.is_translucent() else SOIL_LAYER
	set_cells_terrain_connect(
						layer,
						[coords],
						0,
						WATER_TERRAIN,
						false
					)

func set_goal(coords: Vector2i, farm_item: FarmItem):
	set_cell(ROCK_LAYER, coords, farm_item.get_source_id(), Vector2i.ZERO)
