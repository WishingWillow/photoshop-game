extends Node2D

@export var level : Level
@export var layers : Array[Layer]

func _ready() -> void:
	for layer : Layer in layers: level.register_layer(layer)
