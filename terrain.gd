class_name Terrain
extends Node
# Describes a single tile in a finite world. Contains the biome id, water
# presence, and flow direction.

## Signals
## Enums
enum FLOW_DIRECTION {
	NONE,
	NORTH,
	EAST,
	SOUTH,
	WEST,
}

## Constants
## Exports
## Public
var biome_id: int
var has_water: bool
var flow_direction: int

## Private


## Virtual Methods
func _to_string() -> String:
	var dir := "0"
	match flow_direction:
		FLOW_DIRECTION.NORTH:
			dir = "N"
		FLOW_DIRECTION.EAST:
			dir = "E"
		FLOW_DIRECTION.SOUTH:
			dir = "S"
		FLOW_DIRECTION.WEST:
			dir = "W"

	var water := "w" if has_water else "0"
	return "{%d,%s,%s}" % [biome_id, water, dir]

## Public Methods
## Private Methods
