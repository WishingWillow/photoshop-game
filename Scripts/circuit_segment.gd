## A continuous segment of wire with a start and end point. This is a useful encapsulation because
## a circuit "completes" via a series of segments, each of which can track the position of its
## endpoints and the state of its connection.
class_name CircuitSegment
extends Node2D

var connected : bool = false
var start_cap : CircuitCap
var end_cap : CircuitCap

var color : Consts.CircuitColor

func _init(line_data : IntegerLine, color_in : Consts.CircuitColor) -> void:
	var line := Line2D.new()
	Util.configure_line(line)
	line.points= Util.scale_vec_array_to_unit_size(line_data.points)
	
	color = color_in
	line.default_color = Consts.CircuitColors[color]
	
	start_cap = CircuitCap.new(line_data.points.front(), color_in)
	add_child(start_cap)
	# don't create two caps that are linked as siblings when the "line" is just 1 point
	# otherwise circuit traversing algorithm could keep looping back over the same segment
	if line_data.points.size() <= 1:
		end_cap = start_cap
	else:
		end_cap = CircuitCap.new(line_data.points.back(), color_in)
		CircuitCap.set_siblings(start_cap, end_cap)
		add_child(end_cap)
	
	add_child(line)
	
	z_index = Consts.ZIndex.WIRE
	z_as_relative = false
