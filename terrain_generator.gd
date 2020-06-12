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
	
	var lake_centers := []
	if randi() % 2 == 0:
		lake_centers.append(points[randi() % len(points)])
	
	var lake_count = config.max_lakes - len(lake_centers)
	if lake_count > 1:
		lake_count = randi() % lake_count + 1
	for _i in range(lake_count):
		var x := randi() % config.width
		var y := randi() % config.height
		lake_centers.append(Vector2(x, y))
	
	var s := config.lake_size
	for l in lake_centers:
		var c: Vector2 = l as Vector2
		for i in range(-s, s):
			for j in range(-s, s):
				var p := c + Vector2(i, j)
				if !_in_range(p.x, 0, config.width - 1):
					continue
				if !_in_range(p.y, 0, config.height - 1):
					continue
				if randf() > 0.75:
					map[p.y][p.x].has_water = true
	
	for _i in range(config.erosion_factor):
		_simulate_erosion(map)
	
	for _i in range(config.drain_factor):
		_drain_puddles(map)
	
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


static func _in_range(i: float, start: float, end: float) -> bool:
	return i >= start && i <= end


static func _count_water_neighbors(map: Array, x: int, y: int) -> int:
	var count := 0
	for dx in range(-1,2):
		for dy in range(-1,2):
			var _x := dx + x
			var _y := dy + y
			if _in_range(_y, 0, len(map) - 1) && _in_range(_x, 0, len(map[_y]) - 1):
				var tile: Terrain = map[_y][_x] as Terrain
				if tile.has_water:
					count += 1
	return count


static func _simulate_erosion(map: Array) -> void:
	var to_fill := []
	for y in range(len(map)):
		for x in range(len(map[y])):
			if !map[y][x].has_water && _count_water_neighbors(map, x, y) > 2:
				to_fill.append(Vector2(x,y))
	for i in to_fill:
		var p: Vector2 = i as Vector2
		map[p.y][p.x].has_water = true

static func _drain_puddles(map: Array) -> void:
	var to_drain := []
	for y in range(len(map)):
		for x in range(len(map[y])):
			if map[y][x].has_water && _count_water_neighbors(map, x, y) < 2:
				to_drain.append(Vector2(x,y))
	for i in to_drain:
		var p: Vector2 = i as Vector2
		map[p.y][p.x].has_water = false
