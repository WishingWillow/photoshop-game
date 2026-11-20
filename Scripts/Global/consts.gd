## A class for global-scope constants used throughout the project.
class_name Consts
extends Node

## The layer grid is different from the game canvas grid. UNIT_SCALE is how many canvas units
## equal to one layer unit.
const UNIT_SCALE := 50

## How wide the "wires" are in game canvas units.
const WIRE_WIDTH := 5

## The ends of wire segments have round "caps" that signify where wires on different layers can 
## connect. CAP_RADIUS is the radius of those endpoint circles in game canvas units.
const CAP_RADIUS := 10

enum CircuitColor { RED, BLUE }

## This dictionary defines the screen colors that correspond to the enumerated colors a circuit can
## take.
const CircuitColors : Dictionary[CircuitColor, Color] = {
	CircuitColor.RED : Color("fa7167"),
	CircuitColor.BLUE : Color("027aff")
}

const GridColors : Dictionary[String, Color] = {
	A = Color(0.2, 0.2, 0.2),
	B = Color(0.27, 0.27, 0.27),
}

enum ZIndex {BACKGROUND = -3, LEVEL_BACKGROUND = -2, LAYER_BORDER = -1, WIRE = 0, CAP = 1}
