## An abstract class that encompasses anything that can be loosely be considered a layer
@abstract
class_name AbstractLayer
extends Node2D

## tracks whether the layer should listen to mouse events like dragging and clicking
var mouse_over : bool = false
## mouse_down state is set manually, trumping mouse_over which is set by area signals
var mouse_down : bool = false

@export var data : LayerData

static var notify_layer_placement : Signal = Util.create_static_signal(
	AbstractLayer, 
	"notify_layer_placement", 
	[{"name" : "layer", "type" : TYPE_OBJECT}])

## A layer's rectangle in playspace coordinates
var rect : Rect2:
	get: return Rect2(playspace_coords, data.size)

var playspace_coords := Vector2i.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if (!(mouse_over or mouse_down)): return
	if mouse_down and event.is_action_pressed("drag"): Mouse.follow_mouse(self)
	
	if event.is_action_pressed("select"): mouse_down = true
	if event.is_action_released("select"): 
		mouse_down = false
		print("mouse release")
	if event.is_action_released("drag"):
		mouse_down = false
		Mouse.unfollow_mouse(self)
		snap_to_playspace()
		notify_layer_placement.emit(self)


func snap_to_playspace() -> void:
	var play_x_coord := snappedi(position.x, Consts.UNIT_SCALE)
	var play_y_coord := snappedi(position.y, Consts.UNIT_SCALE)
	position = Vector2(play_x_coord, play_y_coord)
	playspace_coords = position / Consts.UNIT_SCALE
	rect = Rect2(playspace_coords, rect.size)
