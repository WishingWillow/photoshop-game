@tool
extends Node2D

## How large the playspace should be relative to the viewport size
const PLAYSPACE_SCALE : int = 5

@onready var viewport_rect : Rect2 = get_viewport_rect()
var playspace_rect := Rect2(viewport_rect.position, viewport_rect.size * PLAYSPACE_SCALE)


func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var v_rect := get_viewport_rect()
	print(v_rect)
	# set the background to be twice as big as the viewport, centered on the viewport
	var background_rect := Rect2(v_rect.position - v_rect.size / 2, v_rect.size * 2)
	draw_rect(background_rect, Color.BLACK)
