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

## This dictionary defines the screen colors that correspond to the enumerated colors a circuit can
## take.
const CircuitColors : Dictionary[CircuitData.CircuitColor, Color] = {
	CircuitData.CircuitColor.RED : Color.RED,
	CircuitData.CircuitColor.BLUE : Color.BLUE
}
