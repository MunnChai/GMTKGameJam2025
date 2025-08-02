class_name Desktop
extends Node2D

## ---
## DESKTOP
## Your desktop in the game, handles tracking all details about your current desktop windows
## - Your windows, and where they are
## - Your taskbar, and what there is
## - Other misc. desktop details
## ---

## Day fade
signal transition_done()
@onready var fade_rect: ColorRect = $CanvasLayer/DayFade

## Registry of Window Program ID to PackedScene
@export var window_packed_scenes: Dictionary[StringName, PackedScene]

## Increments by one every time a window is opened
## Never decrements...
## Useful for giving every window an ID, or whatever...
static var window_counter := 0

## Psuedo-singleton logic...
static var instance: Desktop
static func is_instanced() -> bool:
	return is_instance_valid(instance)

func _ready() -> void:
	instance = self
	GameStateManager.day_changed.connect(_on_day_changed)

## When we press left mouse button, bring the hovered window to front
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"lmb"):
		if has_hovered_window():
			bring_to_front(get_hovered_window())

#region GUI PROGRAM EXECUTION

## Execute the GUI window program with the specified id,
## passing the specified param dictionary to the boot sequence
## Returns the window after execution
func execute(id: StringName, args: Dictionary = {}) -> DesktopWindow:
	if not window_packed_scenes.has(id):
		print("WARNING! Attempting to instantiate \"" + id + "\" window but it is not in the desktop registry! Do you need to restart the game?")
		return 
	## Make the window
	var window: DesktopWindow = window_packed_scenes.get(id).instantiate()
	%Windows.add_child(window)
	## Boot!
	window.boot(args)
	## Add a task bar icon...
	%TaskBar.add_task(window)
	return window

#endregion

#region WINDOW MANAGEMENT

## The ACTIVE WINDOW is the topmost window. To get it, call get_active_window
## To get the hovered window, call get_hovered_window

## Your current windows, sorted with windows[0] being the topmost and active window 
## and all other windows in descending order
var windows: Array[DesktopWindow] = []

## Opens a window at the front of the desktop
## Only opens the window if it is not already open
## Shifts every other window back
func open_window(window: DesktopWindow) -> bool:
	if has_window(window):
		return false ## Don't open the same window twice!
	if window.is_closing:
		return false ## Don't reopen a closing window!
	windows.push_front(window) ## Open at the front
	window.open_self()
	
	_shift_windows_back()
	
	window_counter += 1
	
	return true

## Brings the given window to the front of the desktop
## If it is not already open, opens it instead of bringing it forward
## Shifts every other window back
func bring_to_front(window: DesktopWindow) -> void:
	if window.is_closing:
		return
	if not has_window(window):
		open_window(window) ## Not open, just open...
		return
	
	if windows[0] == window: ## We are already front
		return
	
	windows.erase(window)
	windows.push_front(window)
	window.bring_self_to_front()
	
	_shift_windows_back()

## Closes the given window, if it is open
## Windows in front are unaffected
## Windows behind are shifted forward
func close_window(window: DesktopWindow) -> void:
	if not has_window(window) or window.is_closing:
		return
	
	%TaskBar.remove_task(window)
	
	var index = get_index_of_window(window)
	windows.erase(window)
	window.close_self()
	
	## Update every window after this one... 
	_shift_windows_forward(index - 1) # -1 since we removed one...

## Returns the given DesktopWindow at the supplied index
## Returns null if index is out of bounds or invalid
func get_desktop_window(index: int) -> DesktopWindow:
	return windows.get(index)
## Returns true if the window is in the stack, false otherwise
func has_window(window: DesktopWindow) -> bool:
	return windows.has(window)
## Returns index or -1 on fail
func get_index_of_window(window: DesktopWindow) -> int:
	return windows.find(window) 

## ACTIVE WINDOW
func has_active_window() -> bool:
	return not windows.is_empty()
func get_active_window() -> DesktopWindow:
	return windows.get(0)

## HOVERED WINDOW
func has_hovered_window() -> bool:
	return get_hovered_window() != null
## Returns the first window with "mouse_hovered"
func get_hovered_window() -> DesktopWindow:
	for window in windows:
		if window.mouse_hovered:
			return window
	return null

## Pushes every window behind the front window back, by updating with new index
func _shift_windows_back(front_index: int = 0) -> void:
	## Push every other window back, after the front index
	for i in range(front_index + 1, windows.size()):
		if not windows[i].is_closing:
			windows[i].shift_self_back(i)

## Shifts every window behind the front window forward, by updating with new index
func _shift_windows_forward(front_index: int = 0) -> void:
	## Push every other window back, after the front index
	for i in range(front_index + 1, windows.size()):
		if not windows[i].is_closing:
			windows[i].shift_self_forward(i)

#endregion

#region DAY TRANSITION

func _on_day_changed(new_day: int) -> void:
	call_deferred("_play_day_transition")

func _play_day_transition() -> void:
	fade_rect.visible = true
	fade_rect.modulate = Color(0,0,0,0)
	fade_rect.move_to_front()
	var tween_out = get_tree().create_tween()
	tween_out.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween_out.tween_property(fade_rect, "modulate:a", 1.0, 1.0)
	tween_out.finished.connect(_on_fade_out_complete)

func _on_fade_out_complete() -> void:
	for w in windows.duplicate():
		close_window(w)
	
	await get_tree().create_timer(1.0).timeout
	
	transition_done.emit()
	var tween_in = get_tree().create_tween()
	tween_in.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_in.tween_property(fade_rect, "modulate:a", 0.0, 1.0)
	tween_in.finished.connect(_on_fade_in_complete)

func _on_fade_in_complete() -> void:
	fade_rect.visible = false

#endregion
