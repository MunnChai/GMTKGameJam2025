extends Node2D

@onready var dotted_line: DottedLine = %DottedLine

var is_pressed: bool = false
var is_enabled: bool = true

func _input(event: InputEvent) -> void:
	if not is_enabled:
		return
	
	if event.is_action_pressed(&"lmb"):
		is_pressed = true
		dotted_line.clear()
		dotted_line.add_global_point(get_global_mouse_position())

	if is_pressed:
		if event is InputEventMouseMotion:
			dotted_line.add_global_point(get_global_mouse_position())

	if event.is_action_released(&"lmb"):
		is_pressed = false
		dotted_line.close()
	
	## Clear selection
	if event.is_action_pressed(&"rmb") and not is_pressed:
		dotted_line.clear()

func enable() -> void:
	is_enabled = true

func disable() -> void:
	is_enabled = false
