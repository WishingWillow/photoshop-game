## A class for global-scope constants used throughout the project.
class_name Consts
extends Node

## The layer grid is different from the game canvas grid. UNIT_SCALE is how many canvas units
## equal to one layer unit.
const UNIT_SCALE := 100

## How wide the "wires" are in game canvas units.
const WIRE_WIDTH := 5

## The ends of wire segments have round "caps" that signify where wires on different layers can 
## connect. CAP_RADIUS is the radius of those endpoint circles in game canvas units.
const CAP_RADIUS := 15

const SEGMENT_WIDTH_EPSILON : float = 0.001

# The enum value here is the same as the types corresponding z index enum value
enum PathType { RAIL = 0, ROAD = 1 }

## This dictionary defines the textures that correspond to the enumerated types a path can
## take.
const PathTexture : Dictionary[PathType, Texture2D] = {
	PathType.ROAD : preload("res://Assets/road.png"),
	PathType.RAIL : preload("res://Assets/rail.png")
}

const CapColors : Dictionary[PathType, Color] = {
	PathType.ROAD : Color(0.105, 0.099, 0.16, 1.0),
	PathType.RAIL : Color(0.105, 0.099, 0.16, 1.0)
}

const GridColors : Dictionary[String, Color] = {
	A = Color(0.345, 0.5, 0.345, 1.0),
	B = Color(0.331, 0.48, 0.331, 1.0),
}

enum ZIndex {BACKGROUND = -3, LEVEL_BACKGROUND = -2, LAYER_BORDER = -1, RAIL = 0, ROAD = 1, CAP = 2}
