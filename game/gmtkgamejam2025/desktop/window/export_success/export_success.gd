class_name ExportSuccess
extends DesktopWindow

## @OVERRIDE
func boot(args: Dictionary = {}) -> void:
	# Pick text
	if args.has("text"):
		%RichTextLabel.text = "Successfully exported to " + args.get("text")
	else:
		print("ERROR: Export Success window executed without \"text\" argument!")
		return
	
	%WindowBar.set_window_title("Export Success")
	
	target_pos = position
	constrain_to_viewport()
