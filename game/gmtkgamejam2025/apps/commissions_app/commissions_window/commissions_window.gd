class_name CommissionsWindow
extends DesktopWindow

## ---
## COMMISSIONS WINDOW
## ---

@onready var commissions_app: CommissionApp = $JuicePivot/MainPanel/VerticalSplit/WindowContent/CommissionsApp

func _ready() -> void:
	super._ready()

## @OVERRIDE
func boot(args: Dictionary = {}) -> void:
	%WindowBar.set_window_title("Commissions!")
	
	if args.has("open_reviews"):
		if args.get("open_reviews"):
			commissions_app.review_button.button_pressed = true
