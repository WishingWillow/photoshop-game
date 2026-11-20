## An abstract class that encompasses anything that can be loosely be considered a layer
@abstract
class_name AbstractLayer
extends Node2D

## tracks whether the layer should listen to mouse events like dragging and clicking
var mouse_over : bool = false
## mouse_down state is set manually, trumping mouse_over which is set by area signals
var mouse_down : bool = false


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
