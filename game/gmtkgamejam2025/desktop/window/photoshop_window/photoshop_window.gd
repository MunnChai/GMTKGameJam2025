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


func open_self() -> void:
	super.open_self()
	photoshop_app.set_focus(true)

func bring_self_to_front() -> void:
	super.bring_self_to_front()
	photoshop_app.set_focus(true)

func shift_self_back(new_index: int) -> void:
	super.shift_self_back(new_index)
	photoshop_app.set_focus(false)

func shift_self_forward(new_index: int) -> void:
	super.shift_self_forward(new_index)
	
	if new_index == 0:
		photoshop_app.set_focus(true)

func close_self() -> void:
	photoshop_app.set_focus(false)
	super.close_self()
