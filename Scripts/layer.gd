## The basic building block of the layer puzzle, a shape with some set of wire segments inside
## of it that can be connected. The script runs in the editor so that the layer data can be shown
## without the game/scene running. 
class_name Layer
extends AbstractLayer

## An array of segments that's populated using the data in data
var path_segments : Array[PathSegment] = []

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


## using create instead of _init because there are layers with exported properties set in the editor
## that _init would override
static func create(data_in : LayerData) -> Layer:
	var layer := Layer.new()
	layer.data = data_in
	return layer


func _ready() -> void:
	parse_data()


func parse_data() -> void:
	# reset data
	adjusted_node.queue_free()
	adjusted_node = Node2D.new()
	path_segments.clear()
	outline = Line2D.new()
	turned_state = 0
	
	# all data needs to be scaled by the UNIT_SCALE, otherwise objects may only be a few pixels
	# wide
	layer_vertices = Util.get_rectangle_vertices(data.size)
	outline.points = Util.scale_vec_array_to_unit_size(layer_vertices)
	for path_data : PathData in data.paths:
		path_segments.append_array(path_data.create_segments(adjusted_node))
	
	#configure outline
	Util.configure_line(outline)
	outline.closed = true
	outline.default_color = Color.DIM_GRAY
	# make sure outline renders behind wires
	outline.z_index = Consts.ZIndex.LAYER_BORDER
	outline.z_as_relative = false
	adjusted_node.add_child(outline)
	
	# configure mouse detection
	var mouse_area := Util.make_polygon_area_2d(outline.points)
	mouse_area.mouse_entered.connect(func(): mouse_over = true)
	mouse_area.mouse_exited.connect(func(): mouse_over = false)
	adjusted_node.add_child(mouse_area)
	
	# set layer z_index for pick ordering purposes. The z index should be the highest available
	# in the layer (roads over layers)
	z_as_relative = false
	z_index = data.paths.reduce(func(highest_index : int, path : PathData): 
		return path.type if path.type > highest_index else highest_index, 0 )
	
	# add adjusted node
	add_child(adjusted_node)


func _unhandled_input(event: InputEvent) -> void:
	if (!(mouse_over or mouse_down)): return
	if (event.is_action_pressed("context_menu")):
		LayerMenu.popup_menu(self)
	super(event)


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
	for segment : PathSegment in path_segments:
		segment.start_cap.set_level_position(pos)
		segment.end_cap.set_level_position(pos)


## layers can be rotated by factors of 90 degrees (a "turn")
func turn(turns : int) -> void:
	turned_state = (turned_state + turns) % 4
	var angle : float = turns * PI / 2
	var angle_state : float = turned_state * PI / 2
	
	# physically rotate node and adjust position so that new top left corner is at layer position
	adjusted_node.rotation = angle_state
	
	# the adjustment is the vector representing the new horizontal side of the layer, 
	# indexed by turned state
	var position_adjustment := -Util.rotate_vector2i(layer_vertices[turned_state], turned_state)
	adjusted_node.position = Util.scale_vec_to_unit_size(position_adjustment)
	
	# update positions of segments/caps
	for segment : PathSegment in path_segments:
		var start := segment.start_cap
		var end := segment.end_cap
		start.layer_position = \
			Util.rotate_vector2i(start.default_layer_position, turned_state) + position_adjustment
		end.layer_position = \
			Util.rotate_vector2i(end.default_layer_position, turned_state) + position_adjustment
		
		# update the line segment rectangles
		for i : int in range(0, segment.segment_rects.size()):
			# note: built-ins are copied by value, so should be re-assigned after manipulation
			var seg_rect := segment.segment_rects[i]
			seg_rect.size = seg_rect.size.rotated(angle)
			seg_rect.position = seg_rect.position.rotated(angle) + Vector2(position_adjustment)
			# adjust for potential negative sizes
			if seg_rect.size.x < 0:
				seg_rect.size.x = abs(seg_rect.size.x)
				# remove epsilon from position
				seg_rect.position.x -= round(seg_rect.size.x)
			if seg_rect.size.y < 0:
				seg_rect.size.y = abs(seg_rect.size.y)
				# remove epsilon from position
				seg_rect.position.y -= round(seg_rect.size.y)
			segment.segment_rects[i] = seg_rect
			
		start.set_level_position(level_position)
		end.set_level_position(level_position)
	
	# rotate the size of the playspace rectangle
	rect.size = abs(rect.size.rotated(angle))


enum {X, Y, Y_X}


func mirror(axis : int) -> void:
	var mirror_transform : Transform2D
	var new_origin := adjusted_node.transform.origin
	match axis:
		X:
			new_origin += Util.scale_vec_to_unit_size(layer_vertices[3])
			mirror_transform = Transform2D(-transform.x, transform.y, new_origin)
		Y:
			new_origin += Util.scale_vec_to_unit_size(layer_vertices[1])
			mirror_transform = Transform2D(transform.x, -transform.y, new_origin)
		# I believe intuition is that y=x and y=-x look reversed from godot's coordinate system
		# (y axis usually faces up instead of down)
		Y_X:
			new_origin += Util.scale_vec_to_unit_size(layer_vertices[2])
			mirror_transform = Transform2D(-transform.y, -transform.x, new_origin)
		-Y_X:
			mirror_transform = Transform2D(transform.y, transform.x, new_origin)
	adjusted_node.transform = adjusted_node.transform * mirror_transform


func slice(axis : int, value : int) -> Layer:
	if not check_valid_slice(axis, value): return null
	
	# split up the layer data by using the segment rectangles
	
	var origin_slice_size := rect.size
	var new_slice_size := rect.size
	# the dimensions of the slice including the origin
	origin_slice_size[axis] = value
	# the dimensions of the new slice
	new_slice_size[axis] = rect.size[axis] - value
	
	var new_slice_position = Vector2i.ZERO
	# origin of the new slice
	new_slice_position[axis] = value
	
	# add epsilon to sizes to account for epsilons added to segment rectangles
	new_slice_size += Vector2.ONE * Consts.SEGMENT_WIDTH_EPSILON
	origin_slice_size += Vector2.ONE * Consts.SEGMENT_WIDTH_EPSILON
	
	var origin_slice_rect := Rect2(Vector2.ZERO, origin_slice_size)
	var new_slice_rect := Rect2(new_slice_position, new_slice_size)
	
	# go through segments, and sort them into which slice they are in. If it spans across both,
	# add the full path segment to an array to split with precision
	var segments_to_slice : Array[PathSegment] = []
	var origin_segments : Array[PathSegment] = []
	var new_segments : Array[PathSegment] = []
	for segment : PathSegment in path_segments:
		# NOTE: this doesn't account for 0 length paths (shouldn't show up in game but came across
		# it in testing
		for seg_rect : Rect2 in segment.segment_rects:
			if not origin_slice_rect.encloses(seg_rect):
				if not new_slice_rect.encloses(seg_rect):
					origin_segments.erase(segment)
					new_segments.erase(segment)
					segments_to_slice.append(segment)
					break
				# the segment could be in the new slice
				if new_segments.is_empty() or not new_segments.back() == segment:
					new_segments.append(segment)
			# the segment could be in the origin slice
			elif origin_segments.is_empty() or not origin_segments.back() == segment:
				origin_segments.append(segment)
	
	# create new LayerDatas and start populating them with known values
	var origin_data := LayerData.new()
	origin_data.size = origin_slice_size
	add_path_data_from_segments(origin_data, Vector2i.ZERO, origin_segments)
	
	var new_data := LayerData.new()
	new_data.size = new_slice_size
	add_path_data_from_segments(new_data, new_slice_position, new_segments)
	
	# now split and sort crossing segments
	for segment : PathSegment in segments_to_slice:
		var origin_path := PathData.new()
		var new_path := PathData.new()
		var origin_line := IntegerLine.new()
		var new_line := IntegerLine.new()
		origin_path.type = segment.type
		origin_path.segments.append(origin_line)
		origin_data.paths.append(origin_path)
		new_path.segments.append(new_line)
		new_path.type = segment.type
		new_data.paths.append(new_path)
		for seg_rect : Rect2 in segment.segment_rects:
			var start_point := Vector2i(round(seg_rect.position))
			var start_in_origin : bool = false
			if origin_slice_rect.has_point(start_point):
				origin_line.points.append(start_point)
				start_in_origin = true
			elif new_slice_rect.has_point(start_point):
				new_line.points.append(start_point - new_slice_position)
			var end_point := Vector2i(round(seg_rect.position + seg_rect.size))
			var end_in_origin : bool = false
			if origin_slice_rect.has_point(end_point):
				origin_line.points.append(end_point)
				end_in_origin = true
			elif new_slice_rect.has_point(end_point):
				new_line.points.append(end_point - new_slice_position)
			
			# the segment crosses the slice boundary, so new points need to be made
			if not start_in_origin == end_in_origin:
				var new_point := start_point
				new_point[axis] = value
				# if the start is in the origin, then we should append to the origin line and
				# prepend to the new line, and vice versa (I think)
				if start_in_origin:
					origin_line.points.push_back(new_point)
					new_line.points.push_front(new_point - new_slice_position)
				else:
					origin_line.points.push_front(new_point)
					new_line.points.push_back(new_point - new_slice_position)
	
	data = origin_data
	parse_data()
	var new_layer := Layer.new()
	new_layer.data = new_data
	new_layer.position = position + Util.scale_vec_to_unit_size(new_slice_position)
	Playspace.add_layer(new_layer)
	return self


func add_path_data_from_segments(
	layer_data : LayerData, segment_offset : Vector2i, segments : Array[PathSegment]) -> void:
	for segment : PathSegment in segments:
		var path_data := PathData.new()
		path_data.type = segment.type
		var line_data := IntegerLine.new()
		path_data.segments.append(line_data)
		for seg_rect : Rect2 in segment.segment_rects:
			line_data.points.append(Vector2i(round(seg_rect.position)) - segment_offset)
		# add the last point
		line_data.points.append(Vector2i(round(
			segment.segment_rects.back().position +\
			segment.segment_rects.back().size)) -\
			segment_offset)
		layer_data.paths.append(path_data)


func check_valid_slice(axis : int, value : int) -> bool:
	var other_axis : int = 1 - axis
	
	# value must be a line inside of the layer (not on the border or beyond)
	if value <= 0 or value >= rect.size[axis]:
		return false
	
	# create a rectangle to check for intersection with path segments
	var slice_pos := Vector2.ZERO
	var slice_size := Vector2.ONE * Consts.SEGMENT_WIDTH_EPSILON
	slice_pos[axis] = value
	slice_size[other_axis] = rect.size[other_axis]
	var slice_rect := Rect2(slice_pos, slice_size)
	
	# look through all layer segments and see if the intersection of this rectangle and any
	# segment rectangle is larger than epsilon. If it is, the intersection is invalid and slicing
	# is not allowed
	for segment : PathSegment in path_segments:
		for seg_rect : Rect2 in segment.segment_rects:
			var intersection := slice_rect.intersection(seg_rect)
			if intersection.size.x > 2 * Consts.SEGMENT_WIDTH_EPSILON \
			or intersection.size.y > 2 * Consts.SEGMENT_WIDTH_EPSILON:
				return false
	return true
