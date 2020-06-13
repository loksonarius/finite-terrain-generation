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
export(int) var river_lod = 6
export(int) var lake_size = 5
export(int) var max_lakes = 3
export(int) var erosion_factor = 3
export(int) var drain_factor = 2
export(Array) var biomes = [0, 1, 2]
export(int) var biome_size = 8
export(int) var biome_growth_factor = 8

## Public
## Private
## OnReady
onready var Decorations = $Decorations

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
	config.river_lod = river_lod
	config.lake_size = lake_size
	config.max_lakes = max_lakes
	config.erosion_factor = erosion_factor
	config.drain_factor = drain_factor
	config.biomes = biomes
	config.biome_size = biome_size
	config.biome_growth_factor = biome_growth_factor
	return config
	

func _generate_terrain() -> void:
	var config := _get_config()
	var terrain : Array = TerrainGenerator.generate_terrain(config)
	
	Decorations.clear()
	for x in range(config.width):
		for y in range(config.height):
			var tile : Terrain = terrain[y][x] as Terrain
			if tile == null:
				continue
			if tile.has_water:
				set_cell(x, y, 0)
			else:
				match tile.biome_id:
					# woodlands
					1:
						if tile.decoration > 0.50:
							set_cell(x, y, 3)
						else:
							set_cell(x, y, 1)
						if tile.decoration > 0.30:
							Decorations.set_cell(x, y, 4)
					# plains
					2:
						set_cell(x, y, 1)
						if tile.decoration > 0.75:
							Decorations.set_cell(x, y, 5)
						elif tile.decoration > 0.35:
							Decorations.set_cell(x, y, 7)
						else:
							Decorations.set_cell(x, y, 6)
					# barren
					_:
						set_cell(x, y, 1)
						if tile.decoration > 0.80:
							Decorations.set_cell(x, y, 4)
						elif tile.decoration > 0.20:
							Decorations.set_cell(x, y, 6)
