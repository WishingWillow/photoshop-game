extends Node2D

@onready var test_scene = $test
@onready var layer_list = $CanvasLayer/UI/MarginContainer/VBoxContainer/HBoxContainer/LayerBar/ScrollContainer/LayerList

func _ready() -> void:
	print("Game scene loaded!")
	print("Available layers: ", test_scene.layers.size())

	layer_list.populate_layers(test_scene.layers)
