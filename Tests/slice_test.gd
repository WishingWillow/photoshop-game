extends Node2D

func _ready() -> void:
	var layer : Layer = $Layer1
	for row : int in layer.rect.size.y + 1:
		print("Is y = ", row, " sliceable: ", layer.check_valid_slice(Layer.Y, row))
	for column : int in layer.rect.size.x + 1:
		print("Is x = ", column, " sliceable: ", layer.check_valid_slice(Layer.X, column))
