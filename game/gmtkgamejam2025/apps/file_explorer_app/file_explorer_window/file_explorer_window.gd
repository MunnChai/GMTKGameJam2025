class_name FileExplorerWindow
extends DesktopWindow

## ---
## FILE EXPLORER WINDOW
## ---

@onready var file_explorer: FileExplorer = %FileExplorer


func _ready() -> void:
	super._ready()

## @OVERRIDE
func boot(args: Dictionary = {}) -> void:
	var upload: bool = false
	if args.get("upload") is bool:
		upload = args.get("upload")
	
	if upload:
		%WindowBar.set_window_title("Select to upload your work")
	else:
		%WindowBar.set_window_title("File Explorer")
	# if this is a upload file window, close this window when a file is selected
	file_explorer.set_upload_mode(upload)
	file_explorer.get_file_system_access().upload_done.connect(_on_close_pressed)
