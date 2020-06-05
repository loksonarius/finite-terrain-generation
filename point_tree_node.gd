class_name PointTreeNode
extends Node
# Abstract data structure representing a regular Tree where each node contains a
# point and a pointer to children. This structure exists to model the sources,
# joins, and exits of a terrain map's rivers. In the context of this structure,
# a root is an exit, a leaf is a source, and other nodes are join points for
# sources.

## Enums
## Constants
## Exports
## Public
var children: Array = []
var value: Vector2 = Vector2.ZERO

## Private
## OnReady

## Virtual Methods
## Public Methods
## Private Methods

