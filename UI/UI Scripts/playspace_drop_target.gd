extends SubViewportContainer

@onready var subviewport: SubViewport = $SubViewport
@onready var playspace: Playspace = $SubViewport/Playspace

var placed_layers: Array[Layer] = []
var moving_layer: Layer = null
var grab_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false

	if data.get("type") != "circuit_layer":
		return false
		
	if not data.get("layer_data") is LayerData:
		return false
	
	var entry = data.get("source_entry")
	
	return (is_instance_valid(entry) and entry is Control and not entry.is_queued_for_deletion())


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not _can_drop_data(at_position, data):
		return
	
	var layer_data: LayerData = data["layer_data"]

	var playspace_position: Vector2 = container_to_playspace(at_position)

	var grid_position := Vector2i(
		roundi(playspace_position.x / Consts.UNIT_SCALE),
		roundi(playspace_position.y / Consts.UNIT_SCALE)
	)

	var placed_layer := Layer.new()
	placed_layer.data = layer_data
	playspace.add_child(placed_layer)
	placed_layers.append(placed_layer)
	
	placed_layer.position = (Vector2(grid_position) * Consts.UNIT_SCALE)
	
	var source_entry: Control = data["source_entry"]
	source_entry.queue_free()

func container_to_playspace(container_position: Vector2) -> Vector2:
	var viewport_position: Vector2 = (container_position * Vector2(subviewport.size) / size)
	
	return (playspace.get_global_transform_with_canvas().affine_inverse() * viewport_position)
	
func _gui_input(event: InputEvent) -> void:
	if moving_layer != null:
		return

	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
			return

		var mouse_pos: Vector2 = container_to_playspace(event.position)

		for i in range(placed_layers.size() - 1, -1, -1):
			var layer: Layer = placed_layers[i]
		
			if not is_instance_valid(layer):
				continue

			if layer.data == null:
				continue

			var local_pos: Vector2 = layer.adjusted_node.to_local(playspace.to_global(mouse_pos))
			var layer_size: Vector2 = (Vector2(layer.data.size) * Consts.UNIT_SCALE)
			var bounds := Rect2(Vector2.ZERO, layer_size)
			
			if bounds.has_point(local_pos):
				moving_layer = layer
				grab_offset = mouse_pos - layer.position
				original_position = layer.position
				
				accept_event()
				return

func _input(event: InputEvent) -> void:
	if not is_instance_valid(moving_layer):
		moving_layer = null
		return

	if not event is InputEventMouse:
		return

	var container_pos: Vector2 = (get_global_transform_with_canvas().affine_inverse() * event.position)
	var mouse_pos: Vector2 = container_to_playspace(container_pos)

	if event is InputEventMouseMotion:
		moving_layer.position = mouse_pos - grab_offset

	elif event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT or event.pressed:
			return

		var inside_playspace := Rect2(Vector2.ZERO, size).has_point(container_pos)

		if inside_playspace:
			var desired_pos: Vector2 = mouse_pos - grab_offset
			var grid_position := Vector2i(
				roundi(desired_pos.x / Consts.UNIT_SCALE),
				roundi(desired_pos.y / Consts.UNIT_SCALE)
			)
			
			moving_layer.position = (Vector2(grid_position) * Consts.UNIT_SCALE)

		else:
			moving_layer.position = original_position

		moving_layer = null
