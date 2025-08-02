class_name TaskBar
extends Control

## ---
## TASK BAR
## The task bar at the bottom of the desktop
## ---

const ICON_SPACING := 4.0

var window_dict: Dictionary[DesktopWindow, TaskBarShortcut]
var shortcuts: Array[TaskBarShortcut]

static var instance: TaskBar
func _ready() -> void:
	instance = self

## Add a new task bar icon for the window, if it doesn't already exist
func add_task(window: DesktopWindow) -> void:
	if window_dict.has(window):
		return
	
	var shortcut := create_task_bar_shortcut()
	shortcut.window_instance = window
	
	if window.taskbar_icon:
		shortcut.set_icon(window.taskbar_icon)
	if window.window_bar:
		shortcut.set_shortcut_name(window.window_bar.window_title)
	
	window_dict.set(window, shortcut)
	shortcuts.append(shortcut)
	
	shortcut.button_pressed = true
	set_active(shortcut)
	
	_arrange_icons()

## Remove the task bar icon for the window, if it exists
func remove_task(window: DesktopWindow) -> void:
	if not window_dict.has(window):
		return
	
	var shortcut: TaskBarShortcut = window_dict.get(window)
	shortcuts.erase(shortcut)
	window_dict.erase(window)
	
	shortcut.remove()
	
	## Get the next one
	if Desktop.instance.has_active_window():
		shortcut = window_dict.get(Desktop.instance.get_active_window())
		set_active(shortcut)
	
	_arrange_icons()

## Create a task bar shortcut for instances of programs
const SHORTCUT_ICON = preload("res://desktop/task_bar/task_bar_shortcut/task_bar_shortcut.tscn")
func create_task_bar_shortcut() -> TaskBarShortcut:
	var new_shortcut_icon := SHORTCUT_ICON.instantiate()
	%TaskBarShortcuts.add_child(new_shortcut_icon)
	#new_shortcut_icon.type = ShortcutIcon.IconType.INSTANCE
	return new_shortcut_icon

## Arrange icons with offset in between
func _arrange_icons() -> void:
	var so_far = 0
	for icon in shortcuts:
		#var offset := (float(i) - (shortcuts.size() / 2.0) + 0.5) * ICON_SPACING
		var offset = so_far
		if not GameSettings.get_setting("reduced_motion", false, "graphics"):
			TweenUtil.whoosh(icon, Vector2(offset, 0))
			TweenUtil.pop_delta(icon, Vector2(0.2, 0.2), 0.5)
		else:
			icon.position = Vector2(offset, 0)
		
		if icon.is_new:
			icon.is_new = false
			icon.position = Vector2(offset, 0)
		so_far += icon.size.x + ICON_SPACING
		#icon.position = Vector2(offset, -32)

func set_active(shortcut: TaskBarShortcut) -> void:
	shortcut.button_pressed = true
	for sc: TaskBarShortcut in shortcuts:
		if sc != shortcut:
			sc.button_pressed = false

func set_active_of_window(window: DesktopWindow) -> void:
	var shortcut = window_dict.get(window)
	set_active(shortcut)
