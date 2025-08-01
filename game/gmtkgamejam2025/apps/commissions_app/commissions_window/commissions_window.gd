class_name CommissionsWindow
extends DesktopWindow

## ---
## COMMISSIONS WINDOW
## ---

func _ready() -> void:
	super._ready()

## @OVERRIDE
func boot(args: Dictionary = {}) -> void:
	%WindowBar.set_window_title("Commissions!")
