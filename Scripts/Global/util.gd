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
