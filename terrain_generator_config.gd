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
var terrain_seed: int = 0
var width: int = 10
var height: int = 10
var biome_ids: Array = [0]
var max_river_sources: int = 2
var max_river_exits: int = 2
var max_lakes: int = 1
var max_biome_bubbles: int = 3

## Private
## OnReady

## Virtual Methods
## Public Methods
## Private Methods

