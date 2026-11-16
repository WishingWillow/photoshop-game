## A continuous segment of wire with a start and end point. This is a useful encapsulation because
## a circuit "completes" via a series of segments, each of which can track the position of its
## endpoints and the state of its connection.
class_name CircuitSegment
extends Node2D

var connected : bool = false
var start_coord : Vector2i
var end_coord : Vector2i

var color : Color

func _init(line_data : IntegerLine, color_in : CircuitData.CircuitColor) -> void:
	var line := Line2D.new()
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.width = Consts.WIRE_WIDTH
	start_coord = line_data.points.front()
	end_coord = line_data.points.back()
	line.points= Util.scale_vec_array_to_unit_size(line_data.points)
	color = Consts.CircuitColors[color_in]
	line.default_color = color
	add_child(line)
	

func _draw() -> void:
	# draw the endcaps on the wire segment to make the points where segments can connect to 
	# each other easily identifiable.
	draw_circle(Util.scale_vec_to_unit_size(start_coord), Consts.CAP_RADIUS, color)
	draw_circle(Util.scale_vec_to_unit_size(end_coord), Consts.CAP_RADIUS, color)
