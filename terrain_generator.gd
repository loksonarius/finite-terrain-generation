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
	assert(_is_config_valid(config))
	seed(config.terrain_seed)
	var map := _new_terrain_map(config.width, config.height)

	# choose random points along the northern map wall for sources
	var max_count := config.max_river_sources
	var northwest := Vector2(config.width - 1, 0)
	var northeast := Vector2(0, 0)
	var sources := _generate_edge_points(max_count, northwest, northeast)
	for source in sources:
		map[source.y as int][source.x as int].has_water = true

	# choose random points along the northern map wall for exits
	# ensuring we have at most as many exits as sources
	var river_trees := []
	var source_count := len(sources)
	var source_dist := []

	max_count = len(sources)
	var southwest := Vector2(config.width - 1, config.height - 1)
	var southeast := Vector2(0, config.height - 1)
	var exits := _generate_edge_points(max_count, southwest, southeast)
	source_count -= len(exits)
	for exit in exits:
		map[exit.y as int][exit.x as int].has_water = true
		var node := PointTreeNode.new()
		node.value = exit
		river_trees.append(node)
		source_dist.append(1)

	# decide how many sources will be assigned to each exit
	var exit := len(exits) - 1
	while source_count > 0:
		var tap := 1 + (randi() % source_count)
		source_dist[exit] += tap
		exit -= 1
		source_count -= tap

	for d in source_dist:
		print(d)

	# add assgined sources to their exit's tree
	var source_offset := 0
	for exit_idx in range(len(exits)):
		for sidx in range(source_offset, source_offset + source_dist[exit_idx]):
			var node : PointTreeNode = river_trees[exit_idx] as PointTreeNode
			var child := PointTreeNode.new()
			child.value = sources[sidx]
			node.children.append(child)
		source_offset += source_dist[exit_idx]

	# create join-points for rivers with mulpitle sources feeding into an exit

	return map

## Private Methods
static func _is_config_valid(config: TerrainGeneratorConfig) -> bool:
	if config.width <= 0: return false
	if config.height <= 0: return false

	if len(config.biome_ids) == 0: return false
	for id in config.biome_ids:
		if (id as int) == null: return false

	var maxes := [
		config.max_river_sources,
		config.max_lakes,
		config.max_biome_bubbles,
	]
	for v in maxes:
		if v < 0: return false

	return true

static func _new_terrain_map(width: int, height: int) -> Array:
	var result := []

	for _i in range(height):
		result.append([])

	for row in result:
		for _i in range(width):
			row.append(Terrain.new())

	return result

static func _generate_edge_points(max_count: int, start: Vector2, end: Vector2) -> Array:
	var dir := (end - start).normalized()
	var variance := 0.20

	var count := 1 + randi() % max_count
	var seg_len := (end - start).length() / count
	var x := start
	print("%s %d %f %s" % [dir, count, seg_len, x])
	var points := [x]
	for _i in range(count - 1):
		var r := rand_range(1.0 - variance, 1.0 + variance)
		x = lerp(x, x + dir * seg_len, r)
		points.append(x)

	return points
