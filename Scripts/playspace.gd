class_name Playspace
extends Node2D


var playspace_size : Vector2

static var instance : Playspace

static var camera : Camera2D

static func add_layer(layer : AbstractLayer) -> void:
	instance.add_child(layer)
	layer.snap_to_playspace()

const levels : Array[LayerData] = [
	preload("res://Assets/Resources/Levels/level1.tres"),
	preload("res://Assets/Resources/Levels/level2.tres"),
	preload("res://Assets/Resources/Levels/level3.tres"),
	preload("res://Assets/Resources/Levels/level4.tres"),
	preload("res://Assets/Resources/Levels/level5.tres"),
]

func initialize() -> void:
	var viewport_size := get_viewport_rect().size
	playspace_size = Vector2(viewport_size.x * 2, viewport_size.y * 5)
	# grid should draw under all other elements
	z_index = Consts.ZIndex.BACKGROUND
	z_as_relative = false
	queue_redraw()
	
	var level_position := Vector2(playspace_size.x / 2, 2 * Consts.UNIT_SCALE)
	# setup levels
	for level_data : LayerData in levels:
		var level := Level.create(level_data)
		level.position = level_position
		level_position.y += (level_data.size.y + 2) * Consts.UNIT_SCALE
		add_layer(level)
		


func _ready() -> void:
	instance = self
	camera = $Camera2D
	call_deferred("initialize")



func _draw() -> void:	
	var row_flip := true
	var grid_square_size := Util.scale_vec_to_unit_size(Vector2.ONE)
	for row in range(0, playspace_size.y + Consts.UNIT_SCALE, Consts.UNIT_SCALE):
		var column_flip := row_flip
		for column in range(0, playspace_size.x + Consts.UNIT_SCALE, Consts.UNIT_SCALE):
			var color := Consts.GridColors.A if column_flip else Consts.GridColors.B
			var grid_square_position := Vector2(column, row)
			draw_rect(Rect2(grid_square_position, grid_square_size), color)
			column_flip = not column_flip
		row_flip = not row_flip
