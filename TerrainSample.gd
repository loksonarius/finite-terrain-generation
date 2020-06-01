#tool
class_name TerrainSample
extends Node2D
# docstring here

## Signals
## Enums
## Constants
var TerrainGenerator = load("res://terrain_generator.gd")
## Exports
## Public
var GeneratedTerrain: Array

## Private
## OnReady

func _ready() -> void:
	var config := TerrainGeneratorConfig.new()
	var terrain : Array = TerrainGenerator.generate_terrain(config)
	for row in terrain:
		print(row)

## Virtual Methods
## Public Methods
## Private Methods

