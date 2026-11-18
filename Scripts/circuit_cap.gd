## A simple struct representing a circuit segment cap, with an integer position and color
class_name CircuitCap
extends Node2D

## position local to its circuit segment/layer
var layer_position : Vector2i
var color : Consts.CircuitColor

## position in a level (set from above)
var level_position : Vector2i
## if a circuit cap is part of a segment, its sibling can be set by its segment
var sibling : CircuitCap = null


func _init(pos : Vector2i, col : Consts.CircuitColor) -> void:
	layer_position = pos
	color = col


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


## adjust the layer and level positions. turn_state is the number of turns from the parent layer's
## default rotation.
func turn(turn_state : int) -> void:
	layer_position = Vector2(layer_position).rotated(turn_state * PI / 2)
	level_position = Vector2(level_position).rotated(turn_state * PI / 2)
