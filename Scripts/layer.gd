@tool
class_name Layer
extends Node2D

@export var _data : LayerData

var circuit_segments : Array[CircuitSegment] = []


func _ready() -> void:
	_parse_data()
	
	
func _parse_data() -> void:
	# all data needs to be scaled by the UNIT_SCALE, otherwise objects may only be a few pixels
	# wide
	$Shape.polygon = Util.scale_vec_array_to_unit_size(_data.shape)
	for circuit_data : CircuitData in _data.circuits:
		var color := Consts.CircuitColors[circuit_data.color]
		for segment_data in circuit_data.segments:
			var segment := CircuitSegment.new(segment_data, circuit_data.color)
			circuit_segments.push_back(segment)
			add_child(segment)
