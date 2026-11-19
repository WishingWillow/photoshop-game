extends Node


# track mouse clicks and movements

enum MouseState {IDLE, CLICK, HOLD, DRAG, DRAG_RELEASE, RELEASE}
var current_state : MouseState

## recorded position of last click
var click_position : Vector2

# mouse position during a drag
var drag_position : Vector2

var mouse_position : Vector2:
	get: return get_viewport().get_mouse_position()

## how far the mouse should travel (squared for efficiency) before a hold is considered a drag
const DRAG_ZONE : float = 200


var _drag_nodes : Array[Node2D]


## A node can request to have its transform updated during a mouses drag state
func add_to_drag(node : Node2D) -> void:
	if node not in _drag_nodes:
		print("ooh")
		_drag_nodes.push_back(node)


func remove_from_drag(node : Node2D) -> void:
	if node in _drag_nodes:
		print("ahh")
		_drag_nodes.erase(node)


## Process input *after* GUI
func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouse: return
	var process_input := true
	while process_input:
		# by default, don't try processing input again
		process_input = false
		match current_state:
			MouseState.IDLE:
				if event.is_action_pressed("select"):
					current_state = MouseState.CLICK
					# process input again
					process_input = true
					continue
			
			MouseState.CLICK:
				# on click events should happen here
				print("click")
				# register click position
				click_position = mouse_position
				current_state = MouseState.HOLD
			
			MouseState.HOLD:
				if event.is_action_released("select"):
					current_state = MouseState.RELEASE
					process_input = true
					continue
				if (event is InputEventMouseMotion 
				and mouse_position.distance_squared_to(click_position) > DRAG_ZONE):
					current_state = MouseState.DRAG
					drag_position = mouse_position
					process_input = true
					continue
			
			MouseState.DRAG:
				if event.is_action_released("select"):
					current_state = MouseState.DRAG_RELEASE
					process_input = true
					continue
				
				# dragging events should happen here
				print("draaaag")
				for node : Node2D in _drag_nodes:
					node.position += (mouse_position - drag_position)
				drag_position = mouse_position
			
			MouseState.DRAG_RELEASE:
				# drag release events should happen here
				print("drag release")
				current_state = MouseState.IDLE
			
			MouseState.RELEASE:
				# on release events should go here
				print("release")
				current_state = MouseState.IDLE
