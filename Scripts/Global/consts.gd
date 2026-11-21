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
const CAP_RADIUS := 25

# The enum value here is the same as the types corresponding z index enum value
enum PathType { RIVER = 0, ROAD = 1 }

## This dictionary defines the textures that correspond to the enumerated types a path can
## take.
const PathTexture : Dictionary[PathType, Texture2D] = {
	PathType.ROAD : preload("res://Assets/road.png"),
	PathType.RIVER : preload("res://Assets/river.png")
}

const GridColors : Dictionary[String, Color] = {
	A = Color(0.2, 0.2, 0.2),
	B = Color(0.27, 0.27, 0.27),
}

enum ZIndex {BACKGROUND = -3, LEVEL_BACKGROUND = -2, LAYER_BORDER = -1, RIVER = 0, ROAD = 1, CAP = 2}
