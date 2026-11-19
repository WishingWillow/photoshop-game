extends Node2D

@export var level : Level
@export var moves : Dictionary[Layer, Move]

func _ready() -> void:
	for layer : Layer in moves.keys(): $Level.register_layer(layer)
	
	print ("checking level complete: ", level.check_complete())
	# execute moves with 2 second delay
	for layer : Layer in moves.keys():
		await get_tree().create_timer(2).timeout
		var move := moves[layer]
		if not move.add_position == Vector2i.ZERO:
			var current_position := layer.level_position
			layer.set_level_position(level, current_position + move.add_position)
		if not move.turn == 0:
			layer.turn(move.turn)
		if not move.mirror == Move.Mirror.NONE:
			assert(false, "mirror not supported right now")
		print ("checking level complete: ", level.check_complete())
	
	print ("test complete.")
