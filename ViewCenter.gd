extends Node2D

const SPEED = 20
const SHIFT_MULT = 10

func _ready() -> void:
	_center_cam()

func _process(_delta) -> void:
	if Input.is_action_just_pressed("reload"):
		_center_cam()

	var dx := Input.get_action_strength("right") - Input.get_action_strength("left")
	var dy := Input.get_action_strength("down") - Input.get_action_strength("up")
	var dis := Vector2(dx, dy).normalized() * SPEED
	if Input.is_action_pressed("shift"):
		dis *= SHIFT_MULT
	translate(dis)

func _center_cam() -> void:
	var center := get_viewport().size * 0.5
	global_position = center
