class_name ErrorPopup
extends DesktopWindow

## ---
## ERROR POPUP (WINDOW)
## A window for error popups
## ---

static var error_counter := 0

func _ready() -> void:
	super._ready()
	
	closed.connect(_on_close)

## @OVERRIDE
func boot(args: Dictionary = {}) -> void:
	# Pick text
	if args.has("text"):
		%RichTextLabel.text = args.get("text")
	
	%WindowBar.set_window_title("ERROR")
	
	position += Vector2(32, -32) * error_counter
	target_pos = position
	constrain_to_viewport()
	
	error_counter += 1

func _on_close() -> void:
	error_counter -= 1
