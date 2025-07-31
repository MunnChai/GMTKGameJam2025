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

func _ready() -> void:
	%Button.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	trigger()

## Trigger this shortcut
func trigger() -> void:
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
