## The basic building block of the layer puzzle, a shape with some set of wire segments inside
## of it that can be connected. The script runs in the editor so that the layer data can be shown
## without the game/scene running. TODO: Inherit from AbstractLayer (requires implementing abstract
## functions). 
@tool
class_name Layer
extends Node2D

## The resource that stores the shape and contents of a layer
@export var _data : LayerData

## An array of segments that's populated using the data in _data
var circuit_segments : Array[CircuitSegment] = []


func _ready() -> void:
	_parse_data()
	
	
func _parse_data() -> void:
	# all data needs to be scaled by the UNIT_SCALE, otherwise objects may only be a few pixels
	# wide
	$Shape.polygon = Util.scale_vec_array_to_unit_size(_data.shape)
	for circuit_data : CircuitData in _data.circuits:
		circuit_segments.append_array(circuit_data.create_segments(self))
