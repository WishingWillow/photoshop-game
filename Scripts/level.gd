## A level is composed of path segments that connect to the edges. Its data can be stored
## as a LayerData
class_name Level
extends AbstractLayer

## A map of path type to the corresponding array of segments (the array is untyped because 
## nested static typing is not allowed)
var path_segments : Dictionary[Consts.PathType, Array]

## A map of cap type to all caps of that type (non-typed array of PathCaps)
var path_caps : Dictionary[Consts.PathType, Array]

## all layers that are currently registered to (used inside) this level
var layers : Array[Layer]

class CapPair:
	var start : PathCap
	var end : PathCap
	func _init(s : PathCap, e : PathCap) -> void:
		start = s
		end = e

## The path caps that need to be connected together to complete the level
var level_caps : Array[CapPair]


static func create(data_in : LayerData) -> Level:
	var layer := Level.new()
	layer.data = data_in
	return layer


func _ready() -> void:
	_init_segments()
	_init_caps()
	
	notify_layer_placement.connect(check_layer_intersection)
	
	z_as_relative = false
	z_index = Consts.ZIndex.LEVEL_BACKGROUND


func _draw() -> void:
	# draw box
	draw_style_box(
		preload("res://Assets/Resources/level_box.tres"), 
		Rect2(Vector2.ZERO, Util.scale_vec_to_unit_size(rect.size)))


func check_layer_intersection(layer : AbstractLayer) -> void:
	if layer.rect.intersects(rect):
		register_layer(layer)
		layer.set_level_position(self, layer.playspace_coords - playspace_coords)
		print("checking level complete: ", check_complete())
		
	elif layers.has(layer):
		unregister_layer(layer)


func _init_segments() -> void:
	for path_data : PathData in data.paths:
		path_segments[path_data.type] = path_data.create_segments(self)


## create a map of cap to position to related path segments
func _init_caps() -> void:
	var all_segments := get_all_segments()
	for segment : PathSegment in all_segments:
		var start_cap := segment.start_cap
		start_cap.set_level_position(Vector2i.ZERO)
		path_caps.get_or_add(start_cap.type, []).append(start_cap)
		
		var end_cap := segment.end_cap
		end_cap.set_level_position(Vector2i.ZERO)
		path_caps.get_or_add(end_cap.type, []).append(end_cap)
		
	# the first and last caps for each type are the level caps. create a copy of the start so the
	# first level segment is treated as connected to it
	for type : Consts.PathType in path_segments.keys():
		var start_cap := PathCap.copy(path_segments[type].front().start_cap)
		var end_cap := (path_segments[type].back() as PathSegment).end_cap
		level_caps.append(CapPair.new(start_cap, end_cap))


## all path segments not sorted into types
func get_all_segments() -> Array[PathSegment]:
	var segments : Array[PathSegment] = []
	return path_segments.keys().reduce(
		func(accum_segments : Array[PathSegment], key : Consts.PathType): 
			accum_segments.append_array(path_segments[key])
			return accum_segments, segments)


func get_all_caps() -> Array[PathCap]:
	var caps : Array[PathCap] = []
	return path_caps.keys().reduce(
		func(accum_caps : Array[PathSegment], key : Consts.PathType): 
			accum_caps.append_array(path_segments[key])
			return accum_caps, caps)


## Check each pair of level caps are connected
func check_complete() -> bool:
	for cap_pair : CapPair in level_caps:
		if not caps_connected(cap_pair.start, cap_pair.end): return false
	
	# every path is connected
	return true


## Traverse the path to see if the start and end are connected to each other
func caps_connected(start : PathCap, end : PathCap) -> bool:
	# trivial cases
	if start == null or end == null: return false
	if start == end: return true
	if start.sibling == end: return true
	if not start.type == end.type: return false
	
	# accumulate an array of all same-typed caps that have the same level position as start
	var position_share : Array[PathCap] = []
	path_caps[start.type].reduce(func(cap_accum, cap): 
		if cap.level_position == start.level_position: cap_accum.append(cap)
		return cap_accum
		, position_share)
	
	# iterate through the shared position caps and see if their sibling is connected to the end cap
	for cap : PathCap in position_share:
		if cap == start: continue
		if cap == end: return true
		if caps_connected(cap.sibling, end): return true
	
	# end cap wasn't found, return false
	return false


func register_layer(layer : Layer) -> void:
	if layers.has(layer): return
	for segment in layer.path_segments:
		path_segments.get_or_add(segment.type, []).append(segment)
		path_caps.get_or_add(segment.type, []).append(segment.start_cap)
		path_caps[segment.type].append(segment.end_cap)
	layers.append(layer)
	layer.registered_with_level = self
	print("registered ", layer)


func unregister_layer(layer : Layer) -> void:
	if not layers.has(layer): return
	for segment in layer.path_segments:
		path_segments[segment.type].erase(segment)
		path_caps[segment.type].erase(segment.start_cap)
		path_caps[segment.type].erase(segment.end_cap)
	layers.erase(layer)
	layer.registered_with_level = null
	print("unregistered ", layer)
