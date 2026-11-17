## A level is composed of circuit segments that connect to the edges. Its data can be stored
## as a LayerData
class_name Level
extends Node2D

@export var _data : LayerData

## A map of circuit color to the corresponding array of segments (the array is untyped because 
## nested static typing is not allowed)
var circuit_segments : Dictionary[Consts.CircuitColor, Array]

## A map of cap position to all circuit segments (non-typed array of CircuitSegment)
## that are connected to that position
var circuit_caps : Dictionary[Consts.CircuitColor, Array]

class CapPair:
	var start : CircuitCap
	var end : CircuitCap
	func _init(s : CircuitCap, e : CircuitCap) -> void:
		start = s
		end = e

## The circuit caps that need to be connected together to complete the level
var level_caps : Array[CapPair]


func _ready() -> void:
	_init_segments()
	_init_caps()


func _init_segments() -> void:
	for circuit_data : CircuitData in _data.circuits:
		circuit_segments[circuit_data.color] = circuit_data.create_segments(self)


## create a map of cap to position to related circuit segments
func _init_caps() -> void:
	var all_segments := get_all_segments()
	for segment : CircuitSegment in all_segments:
		var start_cap := segment.start_cap
		start_cap.set_level_position(Vector2i.ZERO)
		circuit_caps[start_cap.color].append(start_cap)
		
		var end_cap := segment.end_cap
		end_cap.set_level_position(Vector2i.ZERO)
		circuit_caps[end_cap.color].append(end_cap)
		
	# the first and last caps for each color are the level caps. create new copies so that the
	# level segments are treated as "connected" to these caps
	for color : Consts.CircuitColor in circuit_segments.keys():
		var start_cap := CircuitCap.copy(circuit_segments[color].front().start_cap)
		var end_cap := CircuitCap.copy(circuit_segments[color].back().end_cap)
		level_caps.append(CapPair.new(start_cap, end_cap))


## all circuit segments not sorted into colors
func get_all_segments() -> Array[CircuitSegment]:
	var segments : Array[CircuitSegment] = []
	return circuit_segments.keys().reduce(
		func(accum_segments : Array[CircuitSegment], key : Consts.CircuitColor): 
			accum_segments.append_array(circuit_segments[key]), segments)


func get_all_caps() -> Array[CircuitCap]:
	var caps : Array[CircuitCap] = []
	return circuit_caps.keys().reduce(
		func(accum_caps : Array[CircuitSegment], key : Consts.CircuitColor): 
			accum_caps.append_array(circuit_segments[key]), caps)


## Check each pair of level caps are connected
func check_complete() -> bool:
	for cap_pair : CapPair in level_caps:
		if not caps_connected(cap_pair.start, cap_pair.end): return false
	
	# every circuit is connected
	return true


## Traverse the circuit to see if the start and end are connected to each other
func caps_connected(start : CircuitCap, end : CircuitCap) -> bool:
	# trivial cases
	if start == end: return true
	if not start.color == end.color: return false
	
	# Accumulate an array of all same-color caps that have the same level position as start
	var position_share : Array[CircuitCap] = []
	# WIP: circuit_caps[start.color].reduce(func(position_share, cap): )
	return false
