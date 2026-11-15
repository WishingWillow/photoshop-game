class_name Util
extends Node

static func scale_vec_to_unit_size(vector : Vector2i) -> Vector2:
	return vector * Consts.UNIT_SCALE
	
	
static func scale_vec_array_to_unit_size(vector_data : Array[Vector2i]) -> PackedVector2Array:
	return vector_data.map(scale_vec_to_unit_size)
