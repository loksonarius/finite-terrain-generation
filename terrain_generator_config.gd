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
var biome_ids: Array = [0]
var river_lod: int = 2
var lake_size: int = 5
var max_lakes: int = 3
var max_biome_bubbles: int = 3

## Private
## OnReady

## Virtual Methods
## Public Methods
func validate() -> bool:
	if width <= 0: return false
	if height <= 0: return false
	if len(biome_ids) == 0: return false
	for id in biome_ids:
		if (id as int) == null: return false
	var maxes := [
		river_lod,
		lake_size,
		max_lakes,
		max_biome_bubbles,
	]
	for v in maxes:
		if v < 0: return false
	return true
## Private Methods

