extends Node2D

onready var GeneratedTerrain = $GeneratedTerrainTileMap

func _process(_delta) -> void:
	if Input.is_action_just_pressed("reload"):
		GeneratedTerrain.reload()
