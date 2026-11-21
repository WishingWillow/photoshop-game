## A continuous segment of wire with a start and end point. This is a useful encapsulation because
## a path "completes" via a series of segments, each of which can track the position of its
## endpoints and the state of its connection.
class_name PathSegment
extends Node2D

var connected : bool = false
var start_cap : PathCap
var end_cap : PathCap

var type : Consts.PathType

const SEGMENT_WIDTH_EPSILON : float = 0.001

@export var segment_rects : Array[Rect2]

var line_data : IntegerLine

func _init(line_data_in : IntegerLine, type_in : Consts.PathType) -> void:
	line_data = line_data_in
	var line := Line2D.new()
	line.points= Util.scale_vec_array_to_unit_size(line_data.points)
	
	# create rectangles for every line segment in the integer line
	for i : int in range(0, line_data.points.size() - 1):
		var rect_size : Vector2 = abs(line_data.points[i + 1] - line_data.points[i])
		# offset size by epsilon to create rectangle with area
		rect_size += Vector2.ONE * SEGMENT_WIDTH_EPSILON
		segment_rects.append(Rect2(line_data.points[i], rect_size))
	
	type = type_in
	
	line.texture = Consts.PathTexture[type]
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line.width = Consts.UNIT_SCALE
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.round_precision = 5
	
	start_cap = PathCap.new(line_data.points.front(), type_in)
	add_child(start_cap)
	# don't create two caps that are linked as siblings when the "line" is just 1 point
	# otherwise path traversing algorithm could keep looping back over the same segment
	if line_data.points.size() <= 1:
		end_cap = start_cap
	else:
		end_cap = PathCap.new(line_data.points.back(), type_in)
		PathCap.set_siblings(start_cap, end_cap)
		add_child(end_cap)
	
	add_child(line)
	
	z_index = type
	z_as_relative = false
