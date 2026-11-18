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
	end_cap = CircuitCap.new(line_data.points.back(), color_in)
	CircuitCap.set_siblings(start_cap, end_cap)
	
	
	add_child(line)
	add_child(start_cap)
	add_child(end_cap)
	
