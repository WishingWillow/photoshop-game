extends VBoxContainer

@export var layer_entry_scene: PackedScene

const layers : Array[LayerData] = [
	preload("res://Assets/Resources/Layers/layerA.tres"),
	preload("res://Assets/Resources/Layers/layerB.tres"),
	preload("res://Assets/Resources/Layers/layerC.tres"),
	preload("res://Assets/Resources/Layers/layerD.tres"),
	preload("res://Assets/Resources/Layers/layerE.tres"),
	preload("res://Assets/Resources/Layers/layerF.tres"),
	preload("res://Assets/Resources/Layers/layerG.tres"),
]


func _ready() -> void:
	# Clear existing entries
	for child in get_children():
		remove_child(child)
		child.queue_free()

	# Generate an entry for every layer
	for layer_data : LayerData in layers:
		var entry : LayerEntry = layer_entry_scene.instantiate()
		add_child(entry)
		entry.setup(layer_data)
