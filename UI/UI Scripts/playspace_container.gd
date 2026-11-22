class_name PlayspaceContainer
extends SubViewportContainer


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is LayerData


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var layer_data := data as LayerData
	
	var placed_layer := Layer.new()
	placed_layer.data = layer_data
	placed_layer.position = Playspace.instance.get_global_mouse_position()
	Playspace.add_layer(placed_layer)
