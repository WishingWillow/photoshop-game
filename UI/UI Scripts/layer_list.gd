extends VBoxContainer

@export var layer_entry_scene: PackedScene

const CONTEXT_MENU_SCENE = preload("res://UI/Context_Menu.tscn")

var selected_layer: PanelContainer
var active_menu: PopupMenu

func populate_layers(layers: Array[Layer]) -> void:
	# Clear existing entries
	for child in get_children():
		remove_child(child)
		child.queue_free()

	# Generate an entry for every layer
	for layer : Layer in layers:
		var entry = layer_entry_scene.instantiate()
		
		add_child(entry)
		entry.setup(layer)
