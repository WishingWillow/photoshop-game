extends PanelContainer

@onready var preview_viewport: SubViewport = $MarginContainer/PreviewContainer/PreviewViewport
@onready var preview: Node2D = $MarginContainer/PreviewContainer/PreviewViewport/Preview

func setup(layer: Layer) -> void:
	var data: LayerData = layer.data
	
	var preview_layer := Layer.create(data)
	
	preview.add_child(preview_layer) 
	var layer_size := Util.scale_vec_to_unit_size(data.size)
	var viewport_size := Vector2(preview_viewport.size)
	if layer_size.x <= 0 or layer_size.y <= 0:
		return

	preview_layer.position = (viewport_size - layer_size) / 2
