extends Node2D

@onready var dotted_line: DottedLine = %DottedLine

@export var editing_node: Control

const MIN_POINT_DIST: float = 10
var previous_point: Vector2

var is_pressed: bool = false
var is_enabled: bool = true
var is_hovered: bool = false

func _ready() -> void:
	editing_node.mouse_entered.connect(func():
		is_hovered = true)
	editing_node.mouse_exited.connect(func():
		is_hovered = false)

func _process(_delta: float) -> void:
	if not is_enabled:
		return
	
	if not is_hovered:
		return
	
	var pos = get_global_mouse_position()
	
	if Input.is_action_just_pressed(&"lmb"):
		is_pressed = true
		dotted_line.clear()
		if pos.distance_to(previous_point) >= MIN_POINT_DIST:
			dotted_line.add_global_point(pos)
			previous_point = pos

	if is_pressed:
		if pos.distance_to(previous_point) >= MIN_POINT_DIST:
			dotted_line.add_global_point(pos)
			previous_point = pos

	if Input.is_action_just_released(&"lmb"):
		is_pressed = false
		dotted_line.close()
	
	## Clear selection
	if Input.is_action_pressed(&"rmb") and not is_pressed:
		dotted_line.clear()

func enable() -> void:
	is_enabled = true

func disable() -> void:
	is_enabled = false
