class_name PhotoshopWindow
extends DesktopWindow

@onready var photoshop_app: PhotoshopApp = %PhotoshopApp

func boot(args: Dictionary = {}) -> void:
	%WindowBar.set_window_title("PhotoLoop")
	
	if args.size() == 0:
		printerr("WARNING: Photoshop window opened with no args!")
		return
	
	if not args.get("file") is FileResource:
		printerr("WARNING: Photoshop window opened with non-FileResource arg!!!")
		return
	
	var file: File = File.create_from_resource(args.get("file"))
	photoshop_app.set_file(file)
