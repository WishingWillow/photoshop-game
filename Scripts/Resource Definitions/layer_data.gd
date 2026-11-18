## A resource class containing all information to represent a layer, including its shape and inner
## circuits. The resource is composed of distinct sub-resources so that the nested structure can
## be fully traversed in the editor.
class_name LayerData
extends Resource

# Since we're working on an integer grid, the data is represented with integer-typed vector2s.
@export var size : Vector2i # dimensions of a rectangle
@export var circuits : Array[CircuitData]

func _init() -> void:
	# trivial init function to avoid complaints from the editor when creating a new resource
	size = Vector2i.ZERO
	circuits = []
