extends Node


# track mouse clicks and movements
# generates new events for other game nodes to listen to (like dragging)

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
func follow_mouse(node : Node2D) -> void:
	if node not in _drag_nodes:
		_drag_nodes.push_back(node)


func unfollow_mouse(node : Node2D) -> void:
	_drag_nodes.erase(node)


## Process input before GUI
func _input(event: InputEvent) -> void:
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
					# consume the input (nom nom)
					get_viewport().set_input_as_handled()
					current_state = MouseState.DRAG_RELEASE
					process_input = true
					continue
				
				# dragging events should happen here
				press_event("drag")
				for node : Node2D in _drag_nodes:
					node.position += (mouse_position - drag_position) / Playspace.camera.zoom
				drag_position = mouse_position
			
			MouseState.DRAG_RELEASE:
				# drag release events should happen here
				release_event("drag")
				current_state = MouseState.IDLE
			
			MouseState.RELEASE:
				# on release events should go here
				current_state = MouseState.IDLE


func press_event(action : String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)


func release_event(action : String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)
