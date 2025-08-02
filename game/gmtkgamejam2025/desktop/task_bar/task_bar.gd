class_name TaskBar
extends Control

## ---
## TASK BAR
## The task bar at the bottom of the desktop
## ---

@onready var date_label: RichTextLabel = %DateLabel

const ICON_SPACING := 64.0

var window_dict: Dictionary[DesktopWindow, ShortcutIcon]
var shortcuts: Array[ShortcutIcon]

func _ready() -> void:
	GameStateManager.day_changed.connect(update_date_label)

func update_date_label(day: int) -> void:
	var text: String = ""
	match day:
		1:
			text = "30/7/2025"
		2:
			text = "31/7/2025"
		3:
			text = "1/8/2025"
		4:
			text = "2/8/2025"
		5:
			text = "3/8/2025"
	date_label.text = text

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
	
	_arrange_icons()

## Remove the task bar icon for the window, if it exists
func remove_task(window: DesktopWindow) -> void:
	if not window_dict.has(window):
		return
	
	var shortcut: ShortcutIcon = window_dict.get(window)
	shortcuts.erase(shortcut)
	window_dict.erase(window)
	
	shortcut.remove()
	
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
