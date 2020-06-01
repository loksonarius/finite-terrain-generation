class_name TerrainGenerator
extends Node
# Generates a psuedo-random finite 2D terrain based off a seed. The generated
# terrain map is a 2D array of tile descriptors. This is most easily translated
# into a matching TileMap that sets tiles depending on this class' return value.
# The returned array should be accessed with result[y][x] where [0][0] refers to
# the top-right corner of the map and 'y' refers to the row of the 2D map.

## Signals
## Enums
## Constants
## Exports
## Public
## Private

## Public Methods
static func generate_terrain(config: TerrainGeneratorConfig) -> Array:
	assert(_is_config_valid(config))
	seed(config.terrain_seed)
	var result := []

	for i in range(config.height):
		result.append([])

	for row in result:
		for i in range(config.width):
			row.append(Terrain.new())

	return result

## Private Methods
static func _is_config_valid(config: TerrainGeneratorConfig) -> bool:
	if config.width <= 0: return false
	if config.height <= 0: return false

	if len(config.biome_ids) == 0: return false
	for id in config.biome_ids:
		if (id as int) == null: return false

	var maxes := [
		config.max_river_sources,
		config.max_river_exits,
		config.max_lakes,
		config.max_biome_bubbles,
	]
	for v in maxes:
		if v < 0: return false

	return true
