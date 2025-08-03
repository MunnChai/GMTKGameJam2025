class_name EmailWindow
extends DesktopWindow


## ---
## EMAIL WINDOW
## ---

@onready var email_app: EmailApp = %EmailApp

func _ready() -> void:
	super._ready()

## @OVERRIDE
func boot(args: Dictionary = {}) -> void:
	%WindowBar.set_window_title("Emails")
	
