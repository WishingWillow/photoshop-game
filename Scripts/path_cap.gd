## A simple struct representing a path segment cap, with an integer position and type
class_name PathCap
extends Node2D

var type : Consts.PathType

## cap's position in a layer without any transformations applied to the layer
var default_layer_position : Vector2i

## position local to its path segment/layer
var layer_position : Vector2i

## position in a level (set from above)
var level_position : Vector2i
## if a path cap is part of a segment, its sibling can be set by its segment
var sibling : PathCap = null


func _init(pos : Vector2i, typ : Consts.PathType) -> void:
	default_layer_position = pos
	layer_position = pos
	type = typ
	z_index = Consts.ZIndex.CAP
	z_as_relative = false


static func copy(cap : PathCap) -> PathCap:
	var new_cap := new(cap.layer_position, cap.type)
	new_cap.level_position = cap.level_position
	return new_cap


static func set_siblings(cap1 : PathCap, cap2 : PathCap) -> void:
	cap1.sibling = cap2
	cap2.sibling = cap1


func _draw() -> void:
	# draw the endcaps on the wire segment to make the points where segments can connect to 
	# each other easily identifiable.
	draw_circle(
		Util.scale_vec_to_unit_size(layer_position), Consts.CAP_RADIUS, Consts.PathTypes[type])


## set the position of the cap in the level given the position of its layer
func set_level_position(layer_pos : Vector2i) -> void:
	level_position = layer_position + layer_pos
