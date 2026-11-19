extends VBoxContainer

@export var layer_entry_scene: PackedScene

func populate_layers(layers: Array[Layer]) -> void:
	# Clear existing entries
	for child in get_children():
		remove_child(child)
		child.queue_free()

	# Generate an entry for every layer
	for i in range(layers.size()):
		var layer: Layer = layers[i]
		
		var entry = layer_entry_scene.instantiate()
		
		add_child(entry)
		entry.setup(layer)
