class_name InfoPopup
extends DesktopWindow

signal confirmed

## TO DETECT CONFIRMATION
## - Hook up signals to confirmed and closed

## @OVERRIDE
func boot(args: Dictionary = {}) -> void:
	# Pick text
	if args.has("text"):
		%RichTextLabel.text = args.get("text")
	else:
		print("WARNING! Info Popup window executed without \"text\" argument!")
		%RichTextLbale.text = "How did we get here?"
		#return
	
	if args.has("title"):
		%WindowBar.set_window_title(args.get("title"))
	else:
		%WindowBar.set_window_title("INFO")
	
	if args.has("confirm_label"):
		%ConfirmButton.text = args.get("confirm_label")
	
	%ConfirmButton.pressed.connect(_on_confirm)
	
	target_pos = position
	constrain_to_viewport()

func _on_confirm() -> void:
	Desktop.instance.close_window(self)
