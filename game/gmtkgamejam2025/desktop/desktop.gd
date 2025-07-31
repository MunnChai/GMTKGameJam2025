class_name Desktop
extends Node2D

## ---
## DESKTOP
## Your actual desktop
## ---

@export var window_packed_scenes: Dictionary[StringName, PackedScene]

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"lmb"):
		for window in WindowManager.windows:
			if window.mouse_hovered:
				WindowManager.bring_to_front(window)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"lmb"):
		open_window(&"hello_world")

func open_window(id: StringName, window_params: Dictionary = {}):
	var window: DesktopWindow = window_packed_scenes.get(id).instantiate()
	%Windows.add_child(window)
	window.global_position = get_global_mouse_position()
