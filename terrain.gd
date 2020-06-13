class_name Terrain
extends Node
# Describes a single tile in a finite world. Contains the biome id, water
# presence, and flow direction.

## Signals
## Enums
## Constants
## Exports
## Public
var biome_id: int
var decoration: float
var has_water: bool

## Private


## Virtual Methods
func _to_string() -> String:
	var water := "w" if has_water else "l"
	# return "{%d,%s}" % [biome_id, water]
	return water

## Public Methods
## Private Methods
