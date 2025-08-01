class_name FileExplorerWindow
extends DesktopWindow

## ---
## FILE EXPLORER WINDOW
## ---

var upload: bool = false

func _ready() -> void:
	super._ready()

## @OVERRIDE
func boot(args: Dictionary = {}) -> void:
	if args.get("upload") is bool:
		upload = args.get("upload")
	
	if upload:
		%WindowBar.set_window_title("Select to upload your work")
	else:
		%WindowBar.set_window_title("File Explorer")
