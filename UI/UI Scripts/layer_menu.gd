extends PopupMenu

var clicked_layer : Layer

func _ready() -> void:
	visible = false
	var rotate_menu: PopupMenu = get_node("RotateMenu")
	var mirror_menu: PopupMenu = get_node("MirrorMenu")
	set_item_submenu_node(0, rotate_menu)
	set_item_submenu_node(1, mirror_menu)
	
	rotate_menu.id_pressed.connect(func(id): clicked_layer.turn(id))
	mirror_menu.id_pressed.connect(func(id): clicked_layer.mirror(id))
	id_pressed.connect(
		func(id: int) -> void:
			match id:
				1:
					clicked_layer.slice_mode = true
				3:
					clicked_layer.clean_up()
	)

func popup_menu(layer: Layer) -> void:
	clicked_layer = layer
	var mouse_position := Vector2i(get_tree().root.get_mouse_position())
	popup_on_parent(Rect2i(mouse_position, Vector2i.ZERO))
