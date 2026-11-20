## A static class containing helper functions that can be called throughout the project (no 
## Util instance necessary)
class_name Util
extends Node

## Accepts a vector in layer coordinates and scales it to get the corresponding vector
## in game canvas coordinates
static func scale_vec_to_unit_size(vector : Vector2i) -> Vector2:
	return vector * Consts.UNIT_SCALE
	
## Applies scale_vec_to_unit_size to each element in an array of vectors and returns the result
## as a packed vector array (useful for transforming an array of vertices into points for a 
## Polygon2D or Line2D)
static func scale_vec_array_to_unit_size(vector_data : Array[Vector2i]) -> PackedVector2Array:
	return vector_data.map(scale_vec_to_unit_size)


## set the styling of the incoming line
static func configure_line(line : Line2D) -> void:
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.round_precision = 20
	line.width = Consts.WIRE_WIDTH


## returns vertices for a rectangle of a given size
static func get_rectangle_vertices(size : Vector2i) -> Array[Vector2i]:
	var ret : Array[Vector2i] = []
	ret.append(Vector2i.ZERO)
	ret.append(Vector2i(0, size.y))
	ret.append(size)
	ret.append(Vector2i(size.x, 0))
	return ret


static func rotate_vector2i(vec : Vector2i, turns : int) -> Vector2i:
	var rotated := vec
	for i in turns:
		rotated = Vector2i(-rotated.y, rotated.x)
	return rotated


static func make_polygon_area_2d(points : PackedVector2Array) -> Area2D:
	var area := Area2D.new()
	var collision_shape := CollisionPolygon2D.new()
	collision_shape.polygon = points
	area.add_child(collision_shape)
	return area


static func create_static_signal(obj : GDScript, signal_name : String, signal_args : Array = []) -> Signal:
	# https://stackoverflow.com/questions/77026156/how-to-write-a-static-event-emitter-in-gdscript
	obj.add_user_signal(signal_name, signal_args)
	return Signal(obj, signal_name)
