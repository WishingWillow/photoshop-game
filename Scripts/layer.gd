## The basic building block of the layer puzzle, a shape with some set of wire segments inside
## of it that can be connected. The script runs in the editor so that the layer data can be shown
## without the game/scene running. 
class_name Layer
extends AbstractLayer

## An array of segments that's populated using the data in data
var path_segments : Array[PathSegment] = []

## A layer's position in a level should be of a layer's top left corner, 
## regardless of rotations/mirrors. All nodes will parent to this node whose transform 
## will be adjusted based on layer transformations to maintain visual consistency
@onready var adjusted_node := Node2D.new()

var layer_vertices : Array[Vector2i]

## Layer's position in a level relative to the level's origin
var level_position : Vector2i

var registered_with_level : Level = null

## Layers move relative to a level, so a layer's position is controlled by a remote transform
## parented to the level
var level_transform : RemoteTransform2D

## the number of rotations (turns) applied to the layer [0-3]
var turned_state : int = 0

var slice_mode : bool = false:
	set(value):
		slice_mode = value
		queue_redraw()
var slice_candidate : Array[int] = [0, 0]


## using create instead of _init because there are layers with exported properties set in the editor
## that _init would override
static func create(data_in : LayerData) -> Layer:
	var layer := Layer.new()
	layer.data = data_in
	return layer


func clean_up() -> void:
	if registered_with_level: registered_with_level.unregister_layer(self)
	queue_free()


func _ready() -> void:
	parse_data()


func parse_data() -> void:
	# reset data
	adjusted_node.queue_free()
	adjusted_node = Node2D.new()
	path_segments.clear()
	turned_state = 0
	
	# all data needs to be scaled by the UNIT_SCALE, otherwise objects may only be a few pixels
	# wide
	layer_vertices = Util.get_rectangle_vertices(data.size)
	for path_data : PathData in data.paths:
		path_segments.append_array(path_data.create_segments(adjusted_node))
	
	# configure mouse detection
	var mouse_area := Util.make_polygon_area_2d(Util.scale_vec_array_to_unit_size(layer_vertices))
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
	if (!(mouse_over or mouse_down)): 
		if event.is_action_pressed("select"): slice_mode = false
		return
	if (event.is_action_pressed("context_menu")):
		LayerMenu.popup_menu(self) 
	
	if slice_mode:
		if event.is_action_pressed("select"):
			for axis in [X,Y]:
				if slice_candidate[axis] != 0:
					slice(axis, slice_candidate[axis])
					slice_candidate[axis] = 0
					slice_mode = false
					break
		
		const AXIS_EPSILON : int = 15
		var mouse_pos := Playspace.instance.get_global_mouse_position()
		# reset candidates
		slice_candidate = [0,0]
		for axis in [X,Y]:
			var line := snappedf(mouse_pos[axis], Consts.UNIT_SCALE)
			if abs(mouse_pos[axis] - line) <= AXIS_EPSILON:
				@warning_ignore("narrowing_conversion")
				var candidate : int = line / Consts.UNIT_SCALE - rect.position[axis]
				if check_valid_slice(axis, candidate):
					#print("mouse: ", mouse_pos, " axis: ", "X" if axis == X else "Y", " snap: ", line, " value: ", candidate, " VALID")
					slice_candidate[axis] = candidate
					slice_candidate[1-axis] = 0
					break
				#print("mouse: ", mouse_pos, " axis: ", "X" if axis == X else "Y", " snap: ", line, " value: ", candidate)
		queue_redraw()
	
	super(event)


func _draw() -> void:
	# draw box
	draw_style_box(
		preload("res://Assets/Resources/layer_box.tres"), 
		Rect2(rect.position, Util.scale_vec_to_unit_size(rect.size)))
	if not slice_mode: return
	var axis : int = -1
	for which_axis in [X,Y]:
		if slice_candidate[which_axis] != 0:
			axis = which_axis
			break
	if axis < 0: return
	var slice_value = slice_candidate[axis]
	var start := Vector2.ONE * 0.05
	var end : Vector2i = rect.size
	start[axis] = slice_value
	end[axis] = slice_value
	start = start * Consts.UNIT_SCALE
	end = Util.scale_vec_to_unit_size(end)
	draw_line(start, end, Color.WHITE, 2)


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
	rect.size = round(abs(rect.size.rotated(angle)))
	queue_redraw()


enum {X, Y, Y_X, _Y_X}


func mirror(axis : int) -> void:
	var mirror_transform : Transform2D
	var new_origin : Vector2
	var position_adjustment := Vector2i.ZERO
	match axis:
		Y:
			position_adjustment = layer_vertices[3]
			new_origin = Util.scale_vec_to_unit_size(position_adjustment)
			mirror_transform = Transform2D(-transform.x, transform.y, new_origin)
		X:
			position_adjustment = layer_vertices[1]
			new_origin = Util.scale_vec_to_unit_size(position_adjustment)
			mirror_transform = Transform2D(transform.x, -transform.y, new_origin)
		# I believe intuition is that y=x and y=-x look reversed from godot's coordinate system
		# (y axis usually faces up instead of down)
		Y_X:
			position_adjustment = layer_vertices[2]
			new_origin = Util.scale_vec_to_unit_size(position_adjustment)
			mirror_transform = Transform2D(-transform.y, -transform.x, new_origin)
		_Y_X:
			mirror_transform = Transform2D(transform.y, transform.x, new_origin)
	adjusted_node.transform = adjusted_node.transform * mirror_transform
	
	# update mirror transform origin to relative playspace coordinates
	mirror_transform.origin = Vector2(position_adjustment)
	
	# use mirror transform to update segment/cap/rect data
	rect = rect * mirror_transform
	for segment : PathSegment in path_segments:
		var start := segment.start_cap
		var end := segment.end_cap
		start.layer_position = Vector2(start.layer_position) * mirror_transform
		end.layer_position = Vector2(end.layer_position) * mirror_transform
		start.set_level_position(level_position)
		end.set_level_position(level_position)
		for i : int in range(0, segment.segment_rects.size()):
			segment.segment_rects[i] = segment.segment_rects[i] * mirror_transform
			# round rectangle position after transform
			segment.segment_rects[i].position = round(segment.segment_rects[i].position)


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
		# data structure setup
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
		
		# the last rect can tell the next rect which of its points it should push
		var point_to_push : Vector2i
		for i in range(0, segment.segment_rects.size()):
			var seg_rect := segment.segment_rects[i]
			var start_point := Vector2i(round(seg_rect.position))
			var end_point := Vector2i(round(seg_rect.position + seg_rect.size))
			
			var start_in_origin : bool = origin_slice_rect.has_point(start_point)
			var end_in_origin : bool = origin_slice_rect.has_point(end_point)
			
			# for the first rect, look ahead (if possible) to see which point to push
			if i == 0:
				if segment.segment_rects.size() == 1:
					point_to_push = start_point
				else:
					var next_rect := segment.segment_rects[i+1]
					var next_points : Array[Vector2i] = [
						round(next_rect.position),
						round(next_rect.position + next_rect.size)
					]
					point_to_push = start_point if !next_points.has(start_point) else end_point
			
			if start_point == point_to_push:
				if start_in_origin: origin_line.points.append(start_point)
				else: new_line.points.append(start_point - new_slice_position)
				# tell the next rect to push this rect's end point. This ensures no duplicates
				# and good ordering
				point_to_push = end_point
			else:
				if end_in_origin: origin_line.points.append(end_point)
				else: new_line.points.append(end_point - new_slice_position)
				point_to_push = start_point
			
			# if the segment intersects the slice line, create a new point and push to both slices
			if start_in_origin != end_in_origin:
				var new_point := start_point
				new_point[axis] = value
				origin_line.points.append(new_point)
				new_line.points.append(new_point - new_slice_position)
		# push the last point
		if origin_slice_rect.has_point(point_to_push): origin_line.points.append(point_to_push)
		else: new_line.points.append(point_to_push - new_slice_position)
	
	
	data = origin_data
	# remove all old segments/caps before re-parsing layer
	if registered_with_level: registered_with_level.unregister_layer(self)
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
