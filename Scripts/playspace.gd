class_name Playspace
extends Node2D

## How large the playspace should be relative to the viewport size
const PLAYSPACE_SCALE : int = 2

var playspace_size : Vector2

static var instance : Playspace

static func add_layer(layer : AbstractLayer) -> void:
	instance.add_child(layer)
	layer.snap_to_playspace()


func initialize() -> void:
	playspace_size = get_viewport_rect().size * PLAYSPACE_SCALE
	# grid should draw under all other elements
	z_index = Consts.ZIndex.BACKGROUND
	z_as_relative = false
	queue_redraw()

func _ready() -> void:
	instance = self
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
