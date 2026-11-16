## A level is composed of circuit segments that connect to the edges. Its data can be stored
## as a LayerData
@tool
class_name Level
extends Node2D

@export var _data : LayerData

## A map of circuit color to the corresponding array of segments (the array is untyped because 
## nested static typing is not allowed)
@onready var circuit_segments : Dictionary[CircuitData.CircuitColor, Array] = _init_segments()

## A map of cap position to all circuit segments that are connected to that position
@onready var circuit_cap_dictionary : Dictionary[Vector2i, Array] = _init_caps()


func _init_segments() -> Dictionary[CircuitData.CircuitColor, Array]:
	var dictionary : Dictionary[CircuitData.CircuitColor, Array] = {}
	for circuit_data : CircuitData in _data.circuits:
		dictionary[circuit_data.color] = circuit_data.create_segments(self)
	return dictionary


## populate the cap array with the ends of the circuits that are part of the level
func _init_caps() -> Dictionary[Vector2i, Array]:
	var _cap_vec : Array[Vector2i] = []
	# TODO: in progress
	return {}


## Check if each circuit in the level is fully connected.
func check_complete() -> bool:
	for seg_vec : Array[CircuitSegment] in circuit_segments.values():
		var start : CircuitSegment = seg_vec.front()
		# compare start to every other segment. If start is not connected to one, then puzzle is
		# not complete
		for ii in range(1, seg_vec.size()):
			if not segments_connected(start, seg_vec[ii]):
				return false
	
	# every circuit is connected
	return true


func segments_connected(_first : CircuitSegment, _second : CircuitSegment) -> bool:
	return false
