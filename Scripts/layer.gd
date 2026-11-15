@tool
extends Node2D

@export var _data : LayerData
const UNIT_SCALE : int = 50
const LINE_WIDTH : int = 5

const CircuitColors : Dictionary[CircuitData.CircuitColor, Color] = {
	CircuitData.CircuitColor.RED : Color.RED,
	CircuitData.CircuitColor.BLUE : Color.BLUE
}


func _ready() -> void:
	print("calling ready")
	_parse_data()
	
func _parse_data() -> void:
	# all data needs to be scaled by the _unit_scale, otherwise objects may only be a few pixels
	# wide
	$Shape.polygon = _data.shape.map(_scale_to_unit_size)
	for circuit : CircuitData in _data.circuits:
		var circuit_node := Node2D.new()
		$Circuits.add_child(circuit_node)
		print("getting color ", circuit.color)
		var color := CircuitColors[circuit.color]
		for segment in circuit.segments:
			var line := Line2D.new()
			line.width = LINE_WIDTH
			line.points = segment.points.map(_scale_to_unit_size)
			line.default_color = color
			circuit_node.add_child(line)

func _scale_to_unit_size(element : Vector2i) -> Vector2:
	return element * UNIT_SCALE
