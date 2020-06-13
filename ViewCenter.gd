extends Node2D

const ZOOM_FACTOR = 1.1
var _zoom := Vector2.ONE
onready var Camera = $Camera

func _input(event: InputEvent):
	if event is InputEventMouse:
		global_position = event.global_position
		if event.is_pressed():
			match event.button_index:
				BUTTON_WHEEL_UP:
					if _zoom.x > 0.1:
						_zoom /= ZOOM_FACTOR
				BUTTON_WHEEL_DOWN:
					if _zoom.x < 9.0:
						_zoom *= ZOOM_FACTOR
			Camera.zoom = _zoom
	if event is InputEventAction:
		if Input.is_action_just_pressed("reload"):
			_center_cam()


func _ready() -> void:
	_center_cam()


func _center_cam() -> void:
	var center := get_viewport().size * 0.5
	global_position = center
