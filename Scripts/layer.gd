## The basic building block of the layer puzzle, a shape with some set of wire segments inside
## of it that can be connected. The script runs in the editor so that the layer data can be shown
## without the game/scene running. 
class_name Layer
extends Node2D

## The resource that stores the shape and contents of a layer
@export var _data : LayerData

## An array of segments that's populated using the data in _data
var circuit_segments : Array[CircuitSegment] = []

@onready var outline := Line2D.new()

## A layer's position in a level should be of a layer's top left corner, 
## regardless of rotations/mirrors. All nodes will parent to this node whose transform 
## will be adjusted based on layer transformations to maintain visual consistency
@onready var adjusted_node := Node2D.new()

var layer_vertices : Array[Vector2i]

## Layer's position in a level relative to the level's origin
var level_position : Vector2i

## Layers move relative to a level, so a layer's position is controlled by a remote transform
## parented to the level
var level_transform : RemoteTransform2D

## the number of rotations (turns) applied to the layer [0-3]
var turned_state : int = 0

## tracks whether the layer should listen to mouse events like dragging and clicking
var mouse_over : bool = false
## mouse_down state is set manually, trumping mouse_over which is set by area signals
var mouse_down : bool = false


func _ready() -> void:
	_parse_data()


func _unhandled_input(event: InputEvent) -> void:
	if (!(mouse_over or mouse_down)): return
	if mouse_down and event.is_action_pressed("drag"): Mouse.follow_mouse(self)
	
	if event.is_action_pressed("select"): mouse_down = true
	elif event.is_action_released("select"): mouse_down = false
	elif event.is_action_released("drag"): Mouse.unfollow_mouse(self)


func _parse_data() -> void:
	# all data needs to be scaled by the UNIT_SCALE, otherwise objects may only be a few pixels
	# wide
	layer_vertices = Util.get_rectangle_vertices(_data.size)
	outline.points = Util.scale_vec_array_to_unit_size(layer_vertices)
	for circuit_data : CircuitData in _data.circuits:
		circuit_segments.append_array(circuit_data.create_segments(adjusted_node))
	
	#configure outline
	Util.configure_line(outline)
	outline.closed = true
	outline.default_color = Color.DIM_GRAY
	# make sure outline renders behind wires
	outline.z_index = -1
	adjusted_node.add_child(outline)
	
	# configure mouse detection
	var mouse_area := Util.make_polygon_area_2d(outline.points)
	mouse_area.mouse_entered.connect(func(): mouse_over = true)
	mouse_area.mouse_exited.connect(func(): mouse_over = false)
	adjusted_node.add_child(mouse_area)
	
	# add adjusted node
	add_child(adjusted_node)


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
	var angle : float = turned_state * PI / 2
	
	# physically rotate node and adjust position so that new top left corner is at layer position
	adjusted_node.rotation = angle
	
	var position_adjustment := -Util.rotate_vector2i(layer_vertices[turned_state], turned_state)
	adjusted_node.position = Util.scale_vec_to_unit_size(position_adjustment)
	
	# update level positions of circuit caps
	for segment : CircuitSegment in circuit_segments:
		var start := segment.start_cap
		var end := segment.end_cap
		start.layer_position = \
			Util.rotate_vector2i(start.default_layer_position, turned_state) + position_adjustment
		end.layer_position = \
			Util.rotate_vector2i(end.default_layer_position, turned_state) + position_adjustment
		
		start.set_level_position(level_position)
		end.set_level_position(level_position)
