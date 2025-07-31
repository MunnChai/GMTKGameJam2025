class_name TestWindow
extends DesktopWindow

var demo_strings := [
	"Hello world!",
	"Aren't you forgetting something?",
	"Don't you have anything better to do?",
	"...",
	"It seems like there isn't anything here.",
	"How curious."
]

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	
	%RichTextLabel.text = demo_strings[Desktop.window_counter % demo_strings.size()]
	
	#$PanelContainer.mouse_entered.connect(_on_mouse_entered)
	#$PanelContainer.mouse_exited.connect(_on_mouse_exited)
	
	%DragBar.mouse_entered.connect(_on_drag_entered)
	%DragBar.mouse_exited.connect(_on_drag_exited)
	
	%PanelContainer.add_theme_stylebox_override("panel", %PanelContainer.get_theme_stylebox("panel").duplicate())
	%PanelContainer.get_theme_stylebox("panel").bg_color = Color(randf(), randf(), randf())
	
	super._ready()

## @OVERRIDE
func boot(args: Dictionary = {}) -> void:
	print("You are booting the test window!")
	if not args.is_empty():
		print("You have arguments!")
		print("Keys: " + str(args.keys()))
		print("Values: " + str(args.values()))
		print("Arguing is not allowed.")
	else:
		print("You have no arguments.")
		print("I like that about you.")
		print("You do not do silly things like \"talk\", or \"have opinions.\"")
		print("Very well!")
