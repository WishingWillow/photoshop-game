## A simple struct representing a circuit segment cap, with an integer position and color
class_name CircuitCap
extends Node2D

## position local to its circuit segment/layer
var layer_position : Vector2i
var color : CircuitData.CircuitColor

## position in a level (set from above)
var level_position : Vector2i


func _init(pos : Vector2i, col : CircuitData.CircuitColor) -> void:
	layer_position = pos
	color = col


static func copy(cap : CircuitCap) -> CircuitCap:
	return new(cap.layer_position, cap.color)
	
	
func _draw() -> void:
	# draw the endcaps on the wire segment to make the points where segments can connect to 
	# each other easily identifiable.
	draw_circle(
		Util.scale_vec_to_unit_size(layer_position), Consts.CAP_RADIUS, Consts.CircuitColors[color])


func set_level_position(pos : Vector2i) -> void:
	level_position = layer_position + pos
