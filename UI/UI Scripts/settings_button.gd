extends Button

@export var settings_menu_scene: PackedScene


func _on_pressed() -> void:
	var settings = settings_menu_scene.instantiate()
	add_child(settings)
	settings.position = Vector2i(int(global_position.x - settings.size.x),int(global_position.y))
