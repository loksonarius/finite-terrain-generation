#tool
class_name GeneratedTerrainTileMap
extends TileMap
# docstring here

## Signals
## Enums
## Constants
var TerrainGenerator = load("res://terrain_generator.gd")

## Exports

export(int) var terrain_seed = 0
export(int) var width = 32
export(int) var height = 32
export(int) var max_river_sources = 5
export(int) var river_smoothing_factor = 3
export(int) var river_curving_factor = 3.0

## Public
## Private
## OnReady

func _ready() -> void:
	_generate_terrain()

## Virtual Methods
## Public Methods
func reload() -> void:
	_generate_terrain()

## Private Methods
func _get_config() -> TerrainGeneratorConfig:
	var config := TerrainGeneratorConfig.new()
	if terrain_seed == 0:
		config.terrain_seed = OS.get_system_time_msecs()
	else:
		config.terrain_seed = terrain_seed
	config.width = width
	config.height = height
	config.max_river_sources = max_river_sources
	config.river_smoothing_factor = river_smoothing_factor
	config.river_curving_factor = river_curving_factor
	return config

func _generate_terrain() -> void:
	var config := _get_config()
	var terrain : Array = TerrainGenerator.generate_terrain(config)

	for x in range(config.width):
		for y in range(config.height):
			var tile : Terrain = terrain[y][x] as Terrain
			if tile == null:
				continue
			if tile.has_water:
				set_cell(x, y, 0)
			else:
				set_cell(x, y, 1)