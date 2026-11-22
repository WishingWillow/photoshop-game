class_name BoundedCamera2D
extends Camera2D

var target_zoom : float = 1.0

var mouse_pos : Vector2: 
	get: return get_viewport().get_mouse_position()
var drag_pos : Vector2
var dragging : bool = false
var mouse_pos_before_zoom : Vector2
const DEFAULT_ZOOM_MOD : float = 0.1
const MAX_ZOOM : float = 10.0


func lerp_zoom_in() -> void:
	lerp_zoom(DEFAULT_ZOOM_MOD)


func lerp_zoom_out() -> void:
	lerp_zoom(-DEFAULT_ZOOM_MOD)


func lerp_zoom(mod_diff) -> void:
	target_zoom = clampf((1 + mod_diff) * target_zoom, 1.0, MAX_ZOOM)  


func bounded_drag(mouse_delta : Vector2) -> void:
	offset = _bounded_position(offset - mouse_delta / zoom)


func _ready() -> void:
	var defer_defer : Callable = func(): call_deferred("setup_limits")
	defer_defer.call_deferred()

func setup_limits() -> void:
	var playspace : Playspace = get_parent()
	limit_right = playspace.playspace_size.x as int
	limit_bottom = playspace.playspace_size.y as int
	limit_top = 0
	limit_left = 0


func _process(delta: float) -> void:
	if not is_equal_approx(zoom.x, target_zoom):
		mouse_pos_before_zoom = mouse_pos
		zoom = Vector2.ONE * lerpf(zoom.x, target_zoom, 15 * delta)
		offset = _bounded_position(offset + (mouse_pos_before_zoom - mouse_pos))


## bounding position uses Camera2D limits but enforces the limit manually, because otherise
## camera *positions* (not view) is still unbounded
func _bounded_position(pos : Vector2) -> Vector2:
	var camera_right_edge := get_viewport_rect().size.x
	var camera_bottom_edge := get_viewport_rect().size.y
	var x_limit : float = limit_right - (camera_right_edge / zoom.x)
	var y_limit : float = limit_bottom - (camera_bottom_edge / zoom.y)
	return Vector2(clampf(pos.x, limit_left, x_limit), clampf(pos.y, limit_top, y_limit))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_drag_mod"): 
		dragging = true
		drag_pos= mouse_pos
	if event.is_action_released("camera_drag_mod"): 
		dragging = false
	
	if dragging and event is InputEventMouseMotion:
		bounded_drag(mouse_pos - drag_pos)
		drag_pos = mouse_pos
	
	
