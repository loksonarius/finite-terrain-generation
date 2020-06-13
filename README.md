# finite-terrain-generation

_Generate a "natural-looking" 2D, finite terrain on to a TileMap_

## Screenshots

Sample terrains that were generated into a 1024 x 1024 TileMap:

![sample 1](images/sample-1.png)
![sample 2](images/sample-2.png)
![sample 3](images/sample-3.png)

## Usage

To try out the terrain generation scripts in your own project, pull in the
following files:

- `point_path.gd`
- `terrain.gd`
- `terrain_generator.gd`
- `terrain_generator_config.gd`

You can then generate a terrain by calling the `TerrainGenerator` class'
`generate_terrain` function, optionally with a custom `TerrainGeneratorConfig`.
The generated terrain can then be 'rendered' on to a TileMap according to
whatever biome construction and decoration tiles are wanted.

A concrete example of this can be found in the `GeneratedTerrainTileMap.gd`
script.

The code base uses typed GDScript, so it should be easy to pull in to most
projects, including Web-focused ones.

## Demo

This repo contains a fully functional demo that can be used to explore how the
available generation options can affect the terrain. The demo uses the following
controls to view the terrain:

| Input | Description |
| --- | --- |
| Mouse Movement | Move the center focus point of the camera |
| Mouse Wheel Up | Zoom in to the terrain |
| Mouse Wheel Down | Zoom out from the terrain |
| Q | Regenerate the terrain and recenter the camera |

The demo is the default scene, so simply opening the project and hitting "Run"
should work out just fine.
