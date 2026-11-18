extends Node2D

# What you should expect to see:
# scene should start up with level and layer, with circuits disconnected
# a print to the console should say the level is not complete

# after 2 seconds, the layer should be added to the level and moved into position
# a new printout should say the level is complete

func _ready() -> void:
	print("Is level complete: ", $Level.check_complete())
	await get_tree().create_timer(2).timeout
	$Level.add_layer($Layer, Vector2i(1, 1))
	print("Is level complete: ", $Level.check_complete())
	#assert($Level.check_complete())
