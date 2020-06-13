class_name TerrainGeneratorConfig
extends Node
# Encapsulates the possible config options for the TerrainGenerator. This class
# should be passed in to the TerrainGenerator's generate terrain config.
# The possible configuration options for this class are exported as public
# variables.

## Enums
## Constants
## Exports
## Public
var terrain_seed: int = 1
var width: int = 20
var height: int = 10
var river_lod: int = 2
var lake_size: int = 5
var max_lakes: int = 3
var erosion_factor: int = 3
var drain_factor: int = 2
var biomes: Array = [0]
var biome_size: int = 8
var biome_growth_factor: int = 8

## Private
## OnReady

## Virtual Methods
## Public Methods
func validate() -> bool:
	if width <= 0: return false
	if height <= 0: return false
	if len(biomes) == 0: return false
	for id in biomes:
		if (id as int) == null: return false
		if biomes.count(id) > 1: return false
	var maxes := [
		river_lod,
		lake_size,
		max_lakes,
		erosion_factor,
		drain_factor,
		biome_size,
		biome_growth_factor,
	]
	for v in maxes:
		if v < 0: return false
	return true
## Private Methods

