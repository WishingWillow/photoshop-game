extends PopupMenu

var clicked_layer : Layer

func _ready() -> void:
	visible = false
	var rotate_menu: PopupMenu = get_node("RotateMenu")
	var mirror_menu: PopupMenu = get_node("MirrorMenu")
	set_item_submenu_node(0, rotate_menu)
	set_item_submenu_node(2, mirror_menu)
	
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
	id_pressed.connect(
		func(id: int) -> void:
			if id == 1:
				print("Slice!")
	)

func popup_menu(layer: Layer) -> void:
	clicked_layer = layer
	var mouse_position := Vector2i(get_tree().root.get_mouse_position())
	popup_on_parent(Rect2i(mouse_position, Vector2i.ZERO))
