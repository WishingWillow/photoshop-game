## A simple class that contains the data for all segments of a particularly colored circuit on a 
## layer. Rather than just embed this information in a layer, CircuitData has been extracted so 
## that the LayerData resource's nested data can fully visible in the editor.
class_name CircuitData 
extends Resource

enum CircuitColor { RED, BLUE }

@export var color : CircuitColor
@export var segments : Array[IntegerLine]


## The resource can generate its own circuit segments for a requested object
func create_segments(parent : Node2D) -> Array[CircuitSegment]:
	var circuit_segments : Array[CircuitSegment] = []
	for segment_data in segments:
			var segment := CircuitSegment.new(segment_data, color)
			circuit_segments.push_back(segment)
			parent.add_child(segment)
	return circuit_segments
