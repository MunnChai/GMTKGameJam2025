class_name PhotoshopWindow
extends DesktopWindow

@onready var photoshop_app: PhotoshopApp = %PhotoshopApp

func boot(args: Dictionary = {}) -> void:
	if args.size() != 1:
		printerr("WARNING: Photoshop window opened with no texture in args!")
		return
	
	if not args.get("texture") is Texture2D:
		printerr("WARNING: Photoshop window opened with non-Texture2D arg!!!")
		return
	
	photoshop_app.set_texture(args.get("texture"))
