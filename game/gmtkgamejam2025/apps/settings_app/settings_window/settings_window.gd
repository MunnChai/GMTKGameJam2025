class_name SettingsWindow
extends DesktopWindow

## ---
## SETTINGS WINDOW
## ---

func _ready() -> void:
	super._ready()

## @OVERRIDE
func boot(args: Dictionary = {}) -> void:
	%WindowBar.set_window_title("System Settings")
