extends Node2D

@export var level : Level
@export var layers : Array[Layer]
@export var moves : Array[Move]

func _ready() -> void:
	for layer : Layer in layers: level.register_layer(layer)
	
	print ("checking level complete: ", level.check_complete())
	# execute moves with 2 second delay
	for move : Move in moves:
		await get_tree().create_timer(2).timeout
		var layer : Layer = get_node(move.layer_path)
		
		if not move.slice_x == 0:
			assert(layer.slice(Layer.X, move.slice_x) != null)
			continue
		if not move.slice_y == 0:
			assert(layer.slice(Layer.Y, move.slice_y) != null)
			continue
		
		if not move.add_position == Vector2i.ZERO:
			var current_position := layer.level_position
			layer.set_level_position(level, current_position + move.add_position)
		if not move.turn == 0:
			layer.turn(move.turn)
		if not move.mirror == -1:
			layer.mirror(move.mirror)
		
		print ("checking level complete: ", level.check_complete())
	
	print ("test complete.")
