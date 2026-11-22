extends Button

@export var settings_menu_scene: PackedScene

@onready var audio_player: AudioStreamPlayer = %AudioStreamPlayer

func _on_pressed() -> void:
	var settings = settings_menu_scene.instantiate()
	add_child(settings)
	settings.position = Vector2i(int(global_position.x - settings.size.x),int(global_position.y))
	
	var volume_slider: HSlider = settings.get_node("VBoxContainer/VolumeSlider")
	volume_slider.set_value_no_signal(audio_player.volume_linear * 100.0)
	volume_slider.value_changed.connect(_on_volume_changed)
	
func _on_volume_changed(value: float) -> void:
	audio_player.volume_linear = value / 100.0
