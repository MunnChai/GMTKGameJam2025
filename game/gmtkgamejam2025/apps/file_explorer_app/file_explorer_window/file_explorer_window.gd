class_name FileExplorerWindow
extends DesktopWindow

## ---
## FILE EXPLORER WINDOW
## ---

func _ready() -> void:
	super._ready()

## @OVERRIDE
func boot(args: Dictionary = {}) -> void:
	%WindowBar.set_window_title("File Explorer")
