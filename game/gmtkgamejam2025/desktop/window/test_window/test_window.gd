class_name TestWindow
extends DesktopWindow

## ---
## TEST WINDOW
## A window to demonstrate how to setup a window
## Create by executing the hello_world program from desktop
## ---

var demo_strings := [
	"Hello world!",
	"Aren't you forgetting something?",
	"Don't you have anything better to do?",
	"...",
	"It seems like there isn't anything here.",
	"How curious."
]

func _ready() -> void:
	super._ready()

## @OVERRIDE
func boot(args: Dictionary = {}) -> void:
	#print("You are booting the test window!")
	#if not args.is_empty():
		#print("You have arguments!")
		#print("Keys: " + str(args.keys()))
		#print("Values: " + str(args.values()))
		#print("Arguing is not allowed.")
	#else:
		#print("You have no arguments.")
		#print("I like that about you.")
		#print("You do not do silly things like \"talk\", or \"have opinions.\"")
		#print("Very well!")
	
	# Pick text
	%RichTextLabel.text = demo_strings[Desktop.window_counter % demo_strings.size()]
	if args.has("text"):
		%RichTextLabel.text = args.get("text")
	
	# Randomize colour
	%BgPanelContainer.add_theme_stylebox_override("panel", %BgPanelContainer.get_theme_stylebox("panel").duplicate())
	%BgPanelContainer.get_theme_stylebox("panel").bg_color = Color(randf(), randf(), randf())
	if args.has("color"):
		%BgPanelContainer.get_theme_stylebox("panel").bg_color = args.get("color")
	
	%WindowBar.set_window_title("Demo Program " + str(Desktop.window_counter))
