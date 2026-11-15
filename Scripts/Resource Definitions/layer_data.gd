class_name LayerData
extends Resource

# Since we're working on an integer grid, the data is represented with integer-typed vector2s.

@export var shape : Array[Vector2i] # last vertex connects to first
@export var circuits : Array[CircuitData]

func _init() -> void:
	shape = []
	circuits = []
