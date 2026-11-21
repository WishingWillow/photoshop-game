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
	type = type_in
	
	# to try to reduce the warping of line textures, I'm going to break up the line2d into pieces
	# around the joints, though that is more complicated
	if line_data.points.size() <= 2: add_child(initialize_scaled_path(line_data.points))
	else:
		const ELBOW_SIZE : float = 0.5
		var last_elbow_end : Vector2 = Util.scale_vec_to_unit_size(line_data.points.front())
		for i : int in range(1, line_data.points.size() - 1):
			var point := Util.scale_vec_to_unit_size(line_data.points[i])
			# get vectors pointing at the points before and after
			var last_dir := \
				Vector2i(Vector2(line_data.points[i-1] - line_data.points[i]).normalized())
			var next_dir := \
				Vector2i(Vector2(line_data.points[i+1] - line_data.points[i]).normalized())
			var elbow_start : Vector2 = point + Util.scale_vec_to_unit_size(last_dir) * ELBOW_SIZE
			var elbow_end : Vector2 = point + Util.scale_vec_to_unit_size(next_dir) * ELBOW_SIZE
			# make a line between the last point's elbow end and this points elbow start
			add_child(initialize_path([last_elbow_end, elbow_start]))
			# make the elbow line
			add_child(initialize_path([elbow_start, point, elbow_end]))
			# mark the elbow end as the last elbow end
			last_elbow_end = elbow_end
		# make the last line segment
		add_child(initialize_path(
			[Util.scale_vec_to_unit_size(line_data.points.back()), last_elbow_end]))
	
	
	# create rectangles for every line segment in the integer line
	for i : int in range(0, line_data.points.size() - 1):
		var rect_size : Vector2 = abs(line_data.points[i + 1] - line_data.points[i])
		# offset size by epsilon to create rectangle with area
		rect_size += Vector2.ONE * SEGMENT_WIDTH_EPSILON
		segment_rects.append(Rect2(line_data.points[i], rect_size))

	
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
	
	z_index = type
	z_as_relative = false


func initialize_path(points : Array[Vector2]) -> Line2D:
	var line := Line2D.new()
	line.points= points
	
	line.texture = Consts.PathTexture[type]
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line.width = Consts.UNIT_SCALE
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.round_precision = 5
	
	return line


func initialize_scaled_path(points : Array[Vector2i]) -> Line2D:
	return initialize_path(Util.scale_vec_array_to_unit_size(points))
