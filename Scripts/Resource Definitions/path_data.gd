## A simple class that contains the data for all segments of a particularly typed path on a 
## layer. Rather than just embed this information in a layer, PathData has been extracted so 
## that the LayerData resource's nested data can fully visible in the editor.
class_name PathData 
extends Resource


@export var type : Consts.PathType
@export var segments : Array[IntegerLine]


## The resource can generate its own path segments for a requested object
func create_segments(parent : Node2D) -> Array[PathSegment]:
	var path_segments : Array[PathSegment] = []
	for segment_data in segments:
			var segment := PathSegment.new(segment_data, type)
			path_segments.push_back(segment)
			parent.add_child(segment)
	return path_segments
