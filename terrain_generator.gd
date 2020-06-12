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
	# validate config, use config seed, generate blank terrain map
	assert(config.validate())
	seed(config.terrain_seed)
	var map := _new_terrain_map(config.width, config.height)
	
	var source := Vector2(rand_range(0, config.width - 1), 0)
	var exit := Vector2(rand_range(0, config.width - 1), config.height - 1)
	var river_path := PointPath.new(source, exit)
	var points := river_path.detail_path(config.river_lod, config.terrain_seed)
	_render_path(map, points)
	
	source = points[randi() % len(points)] as Vector2
	exit = Vector2([0, config.width - 1][randi() % 2], rand_range(0, source.y))
	river_path = PointPath.new(source, exit)
	points = river_path.detail_path(config.river_lod, config.terrain_seed)
	_render_path(map, points)
	
	return map


## Private Methods
static func _new_terrain_map(width: int, height: int) -> Array:
	var result := []
	# because I can't be bothered to constantly check if we're
	# hitting them edges at each point in the process
	var breathing_room := 2
	
	for _i in range(height + breathing_room):
		result.append([])
	
	for row in result:
		for _i in range(width + breathing_room):
			row.append(Terrain.new())
	
	return result


static func _render_path(map: Array, path: Array) -> void:
	if len(path) < 2:
		return
	
	for i in range(0, len(path) - 1):
		var start: Vector2 = path[i] as Vector2
		var end: Vector2 = path[i + 1] as Vector2
		if start == null || end == null:
			continue
		var points := _rasterize_line(start, end)
		for point in points:
			if point.y >= len(map) || point.x >= len(map[point.y]):
				continue
			if point.y < 0 || point.x < 0:
				continue
		
			var tile : Terrain = map[point.y][point.x] as Terrain
			if tile == null:
				continue
			tile.has_water = true


static func _rasterize_line(start: Vector2, end: Vector2) -> Array:
	var snap := Vector2.ONE
	start = start.snapped(snap)
	end = end.snapped(snap)
	var points := [start]
	
	var dist := ceil((end - start).length())
	for i in range(dist):
		var ratio := i / dist
		var point := start.linear_interpolate(end, ratio).snapped(snap)
		points.append(point)
	
	points += [end]
	return points
