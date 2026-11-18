## The basic building block of the layer puzzle, a shape with some set of wire segments inside
## of it that can be connected. The script runs in the editor so that the layer data can be shown
## without the game/scene running. TODO: Inherit from AbstractLayer (requires implementing abstract
## functions). 
class_name Layer
extends Node2D

## The resource that stores the shape and contents of a layer
@export var _data : LayerData

## An array of segments that's populated using the data in _data
var circuit_segments : Array[CircuitSegment] = []

@onready var outline := Line2D.new()

var level_position : Vector2i

## Layers move relative to a level, so a layer's position is controlled by a remote transform
## parented to the level
var level_transform : RemoteTransform2D

## the number of rotations (turns) applied to the layer [0-3]
var turned_state : int = 0


func _ready() -> void:
	_parse_data()
	
	
func _parse_data() -> void:
	# all data needs to be scaled by the UNIT_SCALE, otherwise objects may only be a few pixels
	# wide
	var rect := Util.get_rectangle_vertices(_data.size)
	outline.points = Util.scale_vec_array_to_unit_size(rect)
	for circuit_data : CircuitData in _data.circuits:
		circuit_segments.append_array(circuit_data.create_segments(self))
	
	#configure outline
	Util.configure_line(outline)
	outline.closed = true
	outline.default_color = Color.DIM_GRAY
	# make sure outline renders behind wires
	outline.z_index = -1
	add_child(outline)


func set_level_position(level : Level, pos : Vector2i) -> void:
	# check if the layer is part of the level. if it isn't, detach itself from another level
	# if necessary and create a new transform
	# TODO: test level switching
	if level_transform and not level_transform.get_parent() == level:
		level_transform.free()
	if not level_transform:
		level_transform = RemoteTransform2D.new()
		level.add_child(level_transform)
		level_transform.remote_path = level_transform.get_path_to(self)
	level_transform.position = Util.scale_vec_to_unit_size(pos)
	level_position = pos
	#update level position of all caps
	for segment : CircuitSegment in circuit_segments:
		segment.start_cap.set_level_position(pos)
		segment.end_cap.set_level_position(pos)


## layers can be rotated by factors of 90 degrees (a "turn")
func turn(turns : int) -> void:
	turned_state = (turned_state + turns) % 4
	# physically rotate node
	rotation = turned_state * PI / 2
	# update level positions of circuit caps
	for segment : CircuitSegment in circuit_segments:
		segment.start_cap.turn(turned_state)
		segment.end_cap.turn(turned_state)
