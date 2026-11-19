extends PanelContainer

@onready var preview_viewport: SubViewport = $MarginContainer/PreviewContainer/PreviewViewport
@onready var preview: Node2D = $MarginContainer/PreviewContainer/PreviewViewport/Preview

func setup(layer: Layer) -> void:
	var data: LayerData = layer._data
	
	var preview_layer := Layer.new()
	preview_layer._data = data
	
	preview.add_child(preview_layer) 
	var layer_size := Vector2i(data.size) * Consts.UNIT_SCALE
	var viewport_size := Vector2i(preview_viewport.size)
	if layer_size.x <= 0 or layer_size.y <= 0:
		return

	preview_layer.position = (viewport_size - layer_size) / 2
