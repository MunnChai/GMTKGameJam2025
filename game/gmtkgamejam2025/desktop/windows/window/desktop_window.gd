class_name DesktopWindow
extends Control

signal opened
signal brought_forward_to_front
signal brought_forward
signal sent_back
signal closed

## ---
## DESKTOP WINDOW
## A single window in the desktop
## Capable of being opened, moved, set active, and closed
## ---

## The window's index
## 0 being highest, larger numbers being further back
var window_index := 0
var is_active := false
var mouse_hovered := false
var drag_hovered := false

var demo_strings := [
	"Hello world!",
	"Aren't you forgetting something?",
	"Don't you have anything better to do?",
	"...",
	"It seems like there isn't anything here.",
	"How curious."
]

static var window_counter := 0
var window_count := 0

@onready var close_button: Button = %CloseButton

func _ready() -> void:
	WindowManager.open_window(self)
	close_button.pressed.connect(_on_close_pressed)
	
	window_count = window_counter
	window_counter += 1
	
	%RichTextLabel.text = demo_strings[window_count % demo_strings.size()]
	
	$PanelContainer.mouse_entered.connect(_on_mouse_entered)
	$PanelContainer.mouse_exited.connect(_on_mouse_exited)
	
	%DragBar.mouse_entered.connect(_on_drag_entered)
	%DragBar.mouse_exited.connect(_on_drag_exited)
	
	$PanelContainer.add_theme_stylebox_override("panel", $PanelContainer.get_theme_stylebox("panel").duplicate())
	$PanelContainer.get_theme_stylebox("panel").bg_color = Color(randf(), randf(), randf())

func _process(delta: float) -> void:
	#print(mouse_hovered)
	pass

func _on_close_pressed() -> void:
	WindowManager.close_window(self)

func _on_mouse_entered() -> void:
	mouse_hovered = true

func _on_mouse_exited() -> void:
	mouse_hovered = false

func _on_drag_entered() -> void:
	drag_hovered = true

func _on_drag_exited() -> void:
	drag_hovered = false

var is_dragging := false
func _input(event: InputEvent) -> void:
	#print(drag_hovered)
	
	if event.is_action_pressed(&"lmb") and drag_hovered:
		is_dragging = true
		WindowManager.bring_to_front(self)
	if event.is_action_released(&"lmb"):
		is_dragging = false
	
	if event is InputEventMouseMotion:
		if is_dragging:
			position += event.screen_relative

#region WINDOW MANAGER HANDLERS

func open_self() -> void:
	window_index = 0
	_update_window_index()
	is_active = true
	opened.emit()
	
	move_to_front()
	
	## TODO: Opening animation

func bring_self_to_front() -> void:
	window_index = 0
	_update_window_index()
	is_active = true
	brought_forward_to_front.emit()
	
	move_to_front()
	
	## TODO: Bringing to front animation

func send_self_back(new_index: int) -> void:
	window_index = new_index
	_update_window_index()
	is_active = false
	sent_back.emit()
	
	## TODO: Sending self back animation

func bring_self_forward(new_index: int) -> void:
	window_index = new_index
	_update_window_index()
	brought_forward.emit()
	if window_index == 0:
		is_active = true
		move_to_front()
		brought_forward_to_front.emit()

func close_self() -> void:
	## CLOSE THIS WINDOW
	is_active = false
	closed.emit()
	
	## TODO: Closing animation
	queue_free()

#endregion

func _update_window_index() -> void:
	pass
