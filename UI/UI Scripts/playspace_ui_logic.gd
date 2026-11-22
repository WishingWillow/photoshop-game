class_name UILogic
extends SubViewportContainer

@onready var subviewport: SubViewport = $SubViewport
@onready var playspace: Playspace = $SubViewport/Playspace

@export var context_menu_scene: PackedScene


static var instance : UILogic


func _ready() -> void:
	instance = self


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false

	if data.get("type") != "layer":
		return false
		
	if not data.get("layer_data") is LayerData:
		return false
	
	var entry = data.get("source_entry")
	
	return (is_instance_valid(entry) and entry is Control and not entry.is_queued_for_deletion())


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not _can_drop_data(at_position, data):
		return
	
	var layer_data: LayerData = data["layer_data"]
	
	var placed_layer := Layer.new()
	placed_layer.data = layer_data
	placed_layer.position = container_to_playspace(at_position)
	Playspace.add_layer(placed_layer)


func container_to_playspace(container_position: Vector2) -> Vector2:
	var viewport_position: Vector2 = (container_position * Vector2(subviewport.size) / size)
	
	return (playspace.get_global_transform_with_canvas().affine_inverse() * viewport_position)
