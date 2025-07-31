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
var window_instance: DesktopWindow

var being_removed := false

func _ready() -> void:
	%Button.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if being_removed:
		return
	trigger()
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
	await TweenUtil.scale_to(self, Vector2.ZERO, 0.3).finished
	queue_free()
