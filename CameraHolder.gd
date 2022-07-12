extends Spatial

# Handles how quickly to rotate
export (float) var rotation_sensitivity = 200

# Define minimum and maximum zoom levels
export (int, 10) var min_zoom = 4
export (int, 100) var max_zoom = 10

# How much the zoom changes each scroll wheel tick
export (int, 10) var zoom_travel = 1

# Adjusts the power of the lerp
export (float, 1, 10) var zoom_lerp = 1

# Defines how much the camera can rotate on the Y axis
export (int, 0, 180) var max_y_rotation = 60

# Defines whether we use the listed actions in the map or just default
# key codes on events
export var use_actions = true
export (Dictionary) var action_map = {
	"ZoomIn": "zoom_in",
	"ZoomOut": "zoom_out",
	"MiddleClick": "middle_click"
}

var middle_mouse_down: bool = false
onready var camera: Camera = $Camera

# Rotation
var rot_x: float = 0
var rot_y: float = 0

# Zoom
onready var zoom_level: float = min_zoom
onready var target_zoom: float = min_zoom

func _ready() -> void:
	zoom_lerp = float(zoom_lerp) / 10

func _process(delta: float) -> void:
	zoom_level = lerp(zoom_level, target_zoom, zoom_lerp)
	camera.transform.origin.y = zoom_level

func _input(event: InputEvent) -> void:
	if not use_actions:
		_handle_non_action_input(event)
	else:
		if event.is_action_pressed(action_map.ZoomIn):
			target_zoom = clamp(zoom_level - zoom_travel, min_zoom, max_zoom)

		if event.is_action_pressed(action_map.ZoomOut):
			target_zoom = clamp(zoom_level + zoom_travel, min_zoom, max_zoom)

		if event.is_action_pressed(action_map.MiddleClick):
			middle_mouse_down = true
		if event.is_action_released(action_map.MiddleClick):
			middle_mouse_down = false

	if middle_mouse_down and event is InputEventMouseMotion:
		var x = event.relative.x
		var y = event.relative.y
		rot_x = lerp(rot_x, rot_x - (x / rotation_sensitivity), .95)
		rot_y = lerp(rot_y, rot_y - (y / rotation_sensitivity), .95)
		rot_y = clamp(rot_y, deg2rad(0), deg2rad(max_y_rotation))
	transform.basis = Basis()
	rotate_object_local(Vector3.UP, rot_x)
	rotate_object_local(Vector3.RIGHT, rot_y)

func _handle_non_action_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP:
			target_zoom = clamp(zoom_level - zoom_travel, min_zoom, max_zoom)
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN:
			target_zoom = clamp(zoom_level + zoom_travel, min_zoom, max_zoom)
	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and event.pressed:
		middle_mouse_down = true
	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and not event.pressed:
		middle_mouse_down = false

