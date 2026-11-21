extends Control

var current_level := 1

@onready var level_menu := $MarginContainer/VBoxContainer/TopBarContainer/LevelMenu
@onready var test_scene = $MarginContainer/VBoxContainer/HBoxContainer/SubViewportContainer/SubViewport/Playspace/test2
@onready var layer_list = $MarginContainer/VBoxContainer/HBoxContainer/LayerBar/ScrollContainer/LayerList

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_level_menu()
	layer_list.populate_layers(test_scene.layers)
	
func populate_level_menu():
	level_menu.clear()
	
	#change to array of existing levels at some point
	for i in range(1,11):
		level_menu.add_item("Level %02d" % i, i-1)
