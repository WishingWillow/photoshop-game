class_name UILogic
extends SubViewportContainer

@onready var subviewport: SubViewport = $SubViewport
@onready var playspace: Playspace = $SubViewport/Playspace

@export var context_menu_scene: PackedScene

var placed_layers: Array[Layer] = []

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
	placed_layers.append(placed_layer)
	


func container_to_playspace(container_position: Vector2) -> Vector2:
	var viewport_position: Vector2 = (container_position * Vector2(subviewport.size) / size)
	
	return (playspace.get_global_transform_with_canvas().affine_inverse() * viewport_position)


static func show_layer_context_menu(clicked_layer: Layer) -> void:
	if instance.context_menu_scene == null:
		return
	
	var menu_instance := instance.context_menu_scene.instantiate()

	instance.get_tree().root.add_child(menu_instance)

	var rotate_menu: PopupMenu = menu_instance.get_node("RotateMenu")
	var mirror_menu: PopupMenu = menu_instance.get_node("MirrorMenu")
	menu_instance.set_item_submenu_node(0, rotate_menu)
	menu_instance.set_item_submenu_node(2, mirror_menu)
	
	rotate_menu.id_pressed.connect(
		func(degrees: int) -> void:
			match degrees:
				0:
					clicked_layer.turn(1)
				1:
					clicked_layer.turn(2)
				2:
					clicked_layer.turn(3)
)

	mirror_menu.id_pressed.connect(
		func(axis: int) -> void:
			match axis:
				0:
					print("Mirror across X")
				1:
					print("Mirror across Y")
				2:
					print("Mirror across Y=X")
)

	menu_instance.id_pressed.connect(
		func(id: int) -> void:
			if id == 1:
				print("Slice!")
)

	menu_instance.popup_hide.connect(menu_instance.queue_free)

	var mouse_position := Vector2i(instance.get_viewport().get_mouse_position())

	menu_instance.popup_on_parent(Rect2i(mouse_position, Vector2i.ZERO))
