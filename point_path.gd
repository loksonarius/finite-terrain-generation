class_name PointPath
extends Node
# Abstract data structure representing a naturally-occurring path in a 2D space.
# Practically speaking, this structure wraps operations around a pair of
# Vector2's. It encompases operations around generating a nice "natural" looking
# curved path between two points.

## Enums
## Constants
const MIN_SHIFT_RANGE = 0.4
const MAX_SHIFT_RANGE = 0.8
## Exports
## Public
var _start: Vector2 = Vector2.ZERO
var _end: Vector2 = Vector2.ZERO

## Private

## Public Methods
# Returns an Array of Vector2's denoting a path between the start and end points
# The lod (level of detail) determines the amount of midpoint splits that will
# be made when generating the path. Keep in mind that the number of midpoints
# (and thus memory consumption) will grow exponentially from this. The minimum
# valid lod used will be 0. The path_seed is used to seed the random number
# generator that will be used to displace midpoints during smoothing.
func detail_path(lod: int, path_seed: int) -> Array:
	if lod < 0:
		lod = 0
	var rng := RandomNumberGenerator.new()
	rng.seed = path_seed
	var points := [_start, _end]
	for _i in range(lod):
		var midpoints := []
		for p in range(len(points) - 1):
			midpoints.append(_pick_midpoint(points[p], points[p+1], rng))
		
		var _points = []
		while !points.empty():
			_points += [points.pop_front(), midpoints.pop_front()]
		_points.pop_back()
		
		points = _points
	return points

## Private Methods
func _pick_midpoint(a: Vector2, b: Vector2, rng: RandomNumberGenerator) -> Vector2:
	var mid: Vector2 = lerp(a, b, 0.5)
	var dis := b - a
	var tang := dis.tangent().normalized()
	var shift := dis.length() * rng.randf_range(MIN_SHIFT_RANGE, MAX_SHIFT_RANGE)
	return mid + tang * shift * (rng.randf() - 0.5)

## Overrides
func _init(start := Vector2.ZERO, end := Vector2.ZERO):
	_start = start
	_end = end
