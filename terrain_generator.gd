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
		if exit < 0:
			exit += len(exits)
		var tap := 1 + (randi() % source_count)
		source_dist[exit] += tap
		exit -= 1
		source_count -= tap

	# add assgined sources to their exit's tree
	var source_offset := 0
	for exit_idx in range(len(exits)):
		for sidx in range(source_offset, source_offset + source_dist[exit_idx]):
			var node : PointTreeNode = river_trees[exit_idx] as PointTreeNode
			if node == null:
				continue
			var child := PointTreeNode.new()
			child.value = sources[sidx]
			node.children.append(child)
		source_offset += source_dist[exit_idx]


	# create join-points for rivers with mulpitle sources feeding into an exit
	for item in river_trees:
		var node : PointTreeNode = item as PointTreeNode
		if node == null:
			continue
		_join_sources(node, config.height)

	# smooth out river points by adding mid-points
	for item in river_trees:
		var node : PointTreeNode = item as PointTreeNode
		if node == null:
			continue
		for _i in range(config.river_smoothing_factor):
			_smooth_paths(node, config.river_curving_factor)

	# render river tiles on to terrain map
	for item in river_trees:
		var node : PointTreeNode = item as PointTreeNode
		if node == null:
			continue
		_render_rivers(map, node)

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
		config.river_smoothing_factor,
		config.max_lakes,
		config.max_biome_bubbles,
	]
	for v in maxes:
		if v < 0: return false

	return true


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


static func _generate_edge_points(max_count: int, start: Vector2, end: Vector2) -> Array:
	var dir := (end - start).normalized()
	var variance := 0.20

	var count := 1 + randi() % max_count
	var seg_len := (end - start).length() / count
	var x := start
	var points := []
	for _i in range(count):
		var r := rand_range(1.0 - variance, 1.0)
		x = lerp(x, x + dir * seg_len, r)
		points.append(x)

	return points


static func _join_sources(tree: PointTreeNode, height: int) -> void:
	var children := []

	# join node pairs while the current node has potential child pairs
	while len(tree.children) > 0:
		# if we only have one child left, stop joins
		if len(tree.children) == 1:
			children.append(tree.children.pop_front())
			continue

		var left : PointTreeNode = tree.children.pop_front() as PointTreeNode
		var right : PointTreeNode = tree.children.pop_front() as PointTreeNode
		assert(left != null)
		assert(right != null)

		# find a suitable join location for the new joining node
		var midpoint := left.value.linear_interpolate(right.value, 0.5)
		var lower_y = max(left.value.y, right.value.y)
		midpoint.y = (tree.value.y - lower_y) / 2.0

		# move joined children under new joining node
		# and replace their spot with the new join node
		var new_node := PointTreeNode.new()
		new_node.value = midpoint
		new_node.children.append(left)
		new_node.children.append(right)
		children.append(new_node)

	tree.children = children


static func _smooth_paths(tree: PointTreeNode, shift_mult: float) -> void:
	var new_children := []
	for child in tree.children:
		var node : PointTreeNode = child as PointTreeNode
		if node == null:
			continue

		# smooth current node's children connections
		var shift_damp := 0.65
		_smooth_paths(node, shift_mult * shift_damp)

		# insert midpoint node between current node and parent
		var shift := (randf() - 0.5) * shift_mult
		var midpoint := tree.value.linear_interpolate(node.value, 0.5)
		var x_dist := min(abs(tree.value.x - node.value.x), 2)
		var displacement := x_dist * shift * shift_mult
		midpoint.x += displacement
		var new_node := PointTreeNode.new()
		new_node.value = midpoint
		new_node.children.append(node)
		new_children.append(new_node)

	tree.children = new_children


static func _render_rivers(map: Array, river: PointTreeNode) -> void:
	var paths := river.node_paths()
	for path in paths:
		assert(len(path) == 2)
		var start := path[0] as Vector2
		var end := path[1] as Vector2
		assert(start != null)
		assert(end != null)

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
