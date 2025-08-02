class_name TaskBarShortcut
extends Button

## Like SHORTCUT ICON, but adapted for the TaskBar

@export var shortcut_name: String = "shortcut"
@export var shortcut_icon: Texture2D = null
@export var min_x_size: float = 88.0

var window_instance: DesktopWindow
var being_removed := false

var is_new := true

func _ready() -> void:
	pressed.connect(_on_pressed)
	
	if shortcut_icon:
		icon = shortcut_icon
	text = shortcut_name
	
	pivot_offset = size / 2.0

func set_icon(_icon: Texture2D) -> void:
	shortcut_icon = _icon
	if shortcut_icon != null:
		icon = shortcut_icon

func set_shortcut_name(_name: String) -> void:
	shortcut_name = _name
	text = shortcut_name

func _on_pressed() -> void:
	if being_removed:
		return
	button_pressed = true
	TaskBar.instance.set_active(self)
	SoundManager.play_global_oneshot(&"ui_basic_click")
	trigger()
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		return
	TweenUtil.pop_delta(self, Vector2(0.2, 0.2), 0.3)

## Trigger this shortcut
func trigger() -> void:
	if being_removed:
		return
	if window_instance:
		if Desktop.is_instanced():
			Desktop.instance.bring_to_front(window_instance)

func remove() -> void:
	if being_removed:
		return
	button_pressed = false
	being_removed = true
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		queue_free()
		return
	await TweenUtil.scale_to(self, Vector2.ZERO, 0.3).finished
	queue_free()
