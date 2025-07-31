extends Node2D

var is_pressed := false

## Here is some TEST logic for drawing with the mouse

## TODO
## - Run check to make sure that we move the mouse enough to warrant selection VERSUS deselection (on simple click with no move)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"lmb"):
		is_pressed = true
		$DottedLine.clear()
		$DottedLine.add_global_point(get_global_mouse_position())

	if is_pressed:
		if event is InputEventMouseMotion:
			$DottedLine.add_global_point(get_global_mouse_position())

	if event.is_action_released(&"lmb"):
		is_pressed = false
		$DottedLine.close()
	
	## Clear selection
	if event.is_action_pressed(&"rmb") and not is_pressed:
		$DottedLine.clear()
