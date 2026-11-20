## A simple struct representing a circuit segment cap, with an integer position and color
class_name CircuitCap
extends Node2D

var color : Consts.CircuitColor

## cap's position in a layer without any transformations applied to the layer
var default_layer_position : Vector2i

## position local to its circuit segment/layer
var layer_position : Vector2i

## position in a level (set from above)
var level_position : Vector2i
## if a circuit cap is part of a segment, its sibling can be set by its segment
var sibling : CircuitCap = null


func _init(pos : Vector2i, col : Consts.CircuitColor) -> void:
	default_layer_position = pos
	layer_position = pos
	color = col
	z_index = Consts.ZIndex.CAP
	z_as_relative = false


static func copy(cap : CircuitCap) -> CircuitCap:
	var new_cap := new(cap.layer_position, cap.color)
	new_cap.level_position = cap.level_position
	return new_cap


static func set_siblings(cap1 : CircuitCap, cap2 : CircuitCap) -> void:
	cap1.sibling = cap2
	cap2.sibling = cap1


func _draw() -> void:
	# draw the endcaps on the wire segment to make the points where segments can connect to 
	# each other easily identifiable.
	draw_circle(
		Util.scale_vec_to_unit_size(layer_position), Consts.CAP_RADIUS, Consts.CircuitColors[color])


## set the position of the cap in the level given the position of its layer
func set_level_position(layer_pos : Vector2i) -> void:
	level_position = layer_position + layer_pos
