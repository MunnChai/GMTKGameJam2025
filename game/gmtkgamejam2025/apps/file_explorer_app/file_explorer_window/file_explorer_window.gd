class_name FileExplorerWindow
extends DesktopWindow

signal upload_done(file_node: FileNode)

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
	
	if args.get("title_override") is String:
		%WindowBar.set_window_title(args.get("title_override"))
	
	# if this is a upload file window, close this window when a file is selected
	file_explorer.set_upload_mode(upload)
	file_explorer.get_file_system_access().upload_done.connect(_on_upload_done)
	
	if args.has("folder_path"):
		for folder_name in args.get("folder_path"):
			file_explorer.file_system.change_directory(folder_name)
	
	SoundManager.play_global_oneshot(&"disk_read")

## Upload selection made
func _on_upload_done(file_node: FileNode) -> void:
	upload_done.emit(file_node) ## Emit signal
	_on_close_pressed() ## Close window
