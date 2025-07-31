class_name TaskBar
extends Control

## ---
## TASK BAR
## The task bar at the bottom of the desktop
## ---

const ICON_SPACING := 48.0

var window_dict: Dictionary[DesktopWindow, ShortcutIcon]
var shortcuts: Array[ShortcutIcon]

## Add a new task bar icon for the window, if it doesn't already exist
func add_task(window: DesktopWindow) -> void:
	if window_dict.has(window):
		return
	
	var shortcut := create_task_bar_shortcut()
	shortcut.window_instance = window
	
	window_dict.set(window, shortcut)
	shortcuts.append(shortcut)
	
	_arrange_icons()

## Remove the task bar icon for the window, if it exists
func remove_task(window: DesktopWindow) -> void:
	if not window_dict.has(window):
		return
	
	var shortcut: ShortcutIcon = window_dict.get(window)
	shortcuts.erase(shortcut)
	window_dict.erase(window)
	
	shortcut.queue_free()
	
	_arrange_icons()

## Create a task bar shortcut for instances of programs
const SHORTCUT_ICON = preload("res://desktop/shortcut_icon/shortcut_icon.tscn")
func create_task_bar_shortcut() -> ShortcutIcon:
	var new_shortcut_icon := SHORTCUT_ICON.instantiate()
	add_child(new_shortcut_icon)
	new_shortcut_icon.type = ShortcutIcon.IconType.INSTANCE
	return new_shortcut_icon

## Arrange icons with offset in between
func _arrange_icons() -> void:
	var i = 0
	for icon in shortcuts:
		var offset := (float(i) - (shortcuts.size() / 2.0) + 0.5) * ICON_SPACING
		TweenUtil.whoosh(icon, Vector2(offset, -32))
		TweenUtil.pop_delta(icon, Vector2(0.2, 0.2), 0.5)
		#icon.position = Vector2(offset, -32)
		i += 1
