extends Node2D

# What you should expect to see:
# scene should start up with level and 2 layers, with circuits disconnected
# a print to the console should say the level is not complete

# after 2 seconds, the red layer should be added to the level and moved into position
# a new printout should say the level is still not complete

# after 2 seconds, the blue layer should be added to the level and moved into position
# a new printout should say that the level is now complete

func _ready() -> void:
	print("Is level complete: ", $Level.check_complete())
	
	await get_tree().create_timer(2).timeout
	$Level.add_layer($Layer1, Vector2i(1, 1))
	print("Is level complete: ", $Level.check_complete())
	
	await get_tree().create_timer(2).timeout
	$Level.add_layer($Layer2, Vector2i(2, 1))
	print("Is level complete: ", $Level.check_complete())
