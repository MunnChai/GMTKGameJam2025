class_name WindowBar
extends Control

signal close_pressed
signal window_title_changed(old_title: String, new_title: String)
signal drag_bar_hover_entered
signal drag_bar_hover_exited

## ---
## WINDOW BAR
## The top standard portion of the window
## Displays the window title and sports the close button, drag bar
## ---

var window: DesktopWindow
var window_title: String = "Computer Program"

func _ready() -> void:
	%WindowTitle.text = window_title
	
	%DragBar.mouse_entered.connect(_on_drag_bar_mouse_enter)
	%DragBar.mouse_exited.connect(_on_drag_bar_mouse_exit)
	
	%CloseButton.pressed.connect(_on_close_pressed)

func assign_window(_window: DesktopWindow) -> void:
	window = _window

func _on_drag_bar_mouse_enter() -> void:
	drag_bar_hover_entered.emit()

func _on_drag_bar_mouse_exit() -> void:
	drag_bar_hover_exited.emit()

func _on_close_pressed() -> void:
	close_pressed.emit()

func set_window_title(title: String) -> void:
	var old := window_title
	window_title = title
	window_title_changed.emit(old, title)
	%WindowTitle.text = window_title

func _process(delta: float) -> void:
	if window and window.is_active:
		# Make bar active
		pass
	else:
		# Make bar inactive
		pass
