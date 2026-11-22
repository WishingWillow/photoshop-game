class_name LayerEntry
extends PanelContainer

@onready var preview_viewport: SubViewport = $MarginContainer/PreviewContainer/PreviewViewport
@onready var preview: Node2D = $MarginContainer/PreviewContainer/PreviewViewport/Preview


var preview_region: Rect2 = Rect2()
var layer_data : LayerData

func setup(data: LayerData) -> void:
	layer_data = data
	var preview_layer := Layer.create(data)
	
	preview.add_child(preview_layer) 
	var layer_size := Util.scale_vec_to_unit_size(data.size)
	var viewport_size := Vector2(preview_viewport.size)
	if layer_size.x <= 0 or layer_size.y <= 0:
		return

	var scale_factor: float = min(viewport_size.x / layer_size.x, viewport_size.y / layer_size.y) * 0.8
	preview_layer.scale = Vector2.ONE * scale_factor

	preview_layer.position = (viewport_size - layer_size * scale_factor) / 2
	
	preview_region = Rect2(preview_layer.position, layer_size * scale_factor)
	
	
func _get_drag_data(_at_position: Vector2) -> Variant:
	if layer_data == null:
		return null
	
	if preview_region.size == Vector2.ZERO:
		return null
		
	var padding: float = 10.0
	var crop_rect: Rect2 = preview_region.grow(padding)
	var cropped_texture := AtlasTexture.new()
	cropped_texture.atlas = preview_viewport.get_texture()
	cropped_texture.region = crop_rect
	cropped_texture.filter_clip = true

	var preview_image := TextureRect.new()
	preview_image.texture = cropped_texture
	preview_image.custom_minimum_size = crop_rect.size
	preview_image.size = crop_rect.size
	preview_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_image.position = Vector2(-padding, -padding)
	preview_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_drag_preview(preview_image)

	return layer_data
