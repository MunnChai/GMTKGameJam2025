class_name ShortcutIcon
extends Control

## ---
## SHORTCUT ICON
## A shortcut icon, that is either one of:
## - Always opening a new instance of a given application
## - Always maximizing a specific instance of a given application
## - Opening if no instance, and going to the instance if there is
## ---

enum IconType {
	BOOT_NEW,
	INSTANCE,
	BOOT_AND_INSTANCE,
}

@export var app_id: StringName = &"hello_world"
@export var type: IconType = IconType.BOOT_NEW
@export var args: Dictionary[StringName, Variant]

@export_category("Display")
@export var shortcut_name: String = "shortcut"
@export var icon: Texture2D = null

var window_instance: DesktopWindow

var being_removed := false

var is_hovered := false

func _ready() -> void:
	%Button.pressed.connect(_on_pressed)
	
	%Button.mouse_entered.connect(_on_mouse_entered)
	%Button.mouse_exited.connect(_on_mouse_exited)
	
	if icon:
		%IconTexture.texture = icon
	%ShortcutName.text = shortcut_name

func set_icon(_icon: Texture2D) -> void:
	icon = _icon
	if icon != null:
		%IconTexture.texture = icon

func set_shortcut_name(_name: String) -> void:
	shortcut_name = _name
	%ShortcutName.text = shortcut_name

func _on_mouse_entered() -> void:
	is_hovered = true
func _on_mouse_exited() -> void:
	is_hovered = false

func _on_pressed() -> void:
	if being_removed:
		return
	SoundManager.play_global_oneshot(&"ui_basic_click")
	trigger()
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		return
	TweenUtil.pop_delta(self, Vector2(0.2, 0.2), 0.3)

## Trigger this shortcut
func trigger() -> void:
	if being_removed:
		return
	match type:
		IconType.BOOT_NEW:
			if Desktop.is_instanced():
				Desktop.instance.execute(app_id, args) ## TODO: How to supply arguments?
		IconType.INSTANCE:
			if window_instance:
				if Desktop.is_instanced():
					Desktop.instance.bring_to_front(window_instance)
		IconType.BOOT_AND_INSTANCE:
			if Desktop.is_instanced():
				if not window_instance:
					window_instance = Desktop.instance.execute(app_id, args)
				else:
					Desktop.instance.bring_to_front(window_instance)

func remove() -> void:
	if being_removed:
		return
	being_removed = true
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		queue_free()
		return
	await TweenUtil.scale_to(self, Vector2.ZERO, 0.3).finished
	queue_free()

@onready var base_pos: Vector2 = %Circle.position
@onready var target_pos := base_pos

func _process(delta: float) -> void:
	target_pos = base_pos
	if window_instance and window_instance.is_active:
		target_pos += Vector2.UP * 8.0
	if is_hovered:
		target_pos += Vector2.UP * 6.0
	
	if not GameSettings.get_setting("reduced_motion", false, "graphics"):
		%Circle.position = MathUtil.decay(%Circle.position, target_pos, 15.0, delta)
	else:
		%Circle.position = base_pos
