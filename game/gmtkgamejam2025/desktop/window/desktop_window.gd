class_name DesktopWindow
extends ReferenceRect

signal opened
signal brought_to_front(explicit: bool) 
# Explicit indicates if the player CLICKED on the window to bring it to front
# It is implicit (not explicit) if the player CLOSED a window in front of this one to bring this window to front
signal shifted_forward
signal shifted_back
signal closed

signal drag_started
signal drag_released
signal drag_moved(delta: Vector2)

## ---
## DESKTOP WINDOW
## ABSTRACT base class!!!
## A single window in the desktop
## Capable of being opened, moved, set active, and closed
## ---
## NOTE: TO CREATE A NEW WINDOW
## Reference the test window...

## - Extend this script (Don't make an inherited scenes unless needed, those are kinda scuffed)
## - Create a new scene using a ReferenceRect node
## - Attach this script
## - Set the ReferenceRect size to encompass the content (used for mouse detection)
## - Make sure that all CONTROL NODES in your content use Mouse: Pass (Propogate Up),
##   so that all mouse events will be able to be detected by the window
## - If using JuicePivot (for tweening/rotation), make sure all content is a child of that 
##   (including the window bar) and make sure that the JuicePivot is in the center!
## ---

@export var window_bar: WindowBar

## The window's index
## 0 being highest, larger numbers being further back
var window_index := 0
var is_active := false
var is_closing := false
var all_clear_for_queue_free := false

var mouse_hovered := false # Hovered over anywhere on the window?
var drag_hovered := false # Hovered over drag bar?
var is_dragging := false # Clicked while hovering over drag bar?

func _ready() -> void:
	if Desktop.is_instanced():
		Desktop.instance.open_window(self)
	
	center_window_to(Vector2.ZERO)
	
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	
	if window_bar:
		window_bar.close_pressed.connect(_on_close_pressed)
		window_bar.drag_bar_hover_entered.connect(_on_drag_entered)
		window_bar.drag_bar_hover_exited.connect(_on_drag_exited)
	else:
		print("WARNING! Creating a window without an initial window bar, is this intentional?")

## @ABSTRACT
## Function called when a program window is "executed" via the desktop
## Override to supply your own startup behaviour
func boot(args: Dictionary = {}) -> void:
	pass

## @ABSTRACT
## Function called when a program window is marked for closing
## Override to supply your own shutdown behaviour
func close() -> void:
	while not all_clear_for_queue_free:
		move_to_front()
		await get_tree().process_frame
	queue_free()

func _process(delta: float) -> void:
	position = MathUtil.decay(position, target_pos, 64.0, delta)
	constrain_to_viewport()

func _on_close_pressed() -> void:
	if Desktop.is_instanced() and not is_closing:
		Desktop.instance.close_window(self)

func _on_mouse_entered() -> void:
	mouse_hovered = true
func _on_mouse_exited() -> void:
	mouse_hovered = false

## When input is recieved for this window...
func _input(event: InputEvent) -> void:
	handle_drag_input(event)

#region WINDOW MOVEMENT

@onready var target_pos := position

func _on_drag_entered() -> void:
	drag_hovered = true
func _on_drag_exited() -> void:
	drag_hovered = false

func handle_drag_input(event: InputEvent) -> void:
	if is_closing:
		return
	
	## DRAG LOGIC
	if event.is_action_pressed(&"lmb") and drag_hovered:
		is_dragging = true
		drag_started.emit()
	if event.is_action_released(&"lmb"):
		is_dragging = false
		drag_released.emit()
	
	if event is InputEventMouseMotion:
		if is_dragging:
			target_pos += event.relative
			drag_moved.emit(event.relative)
			constrain_to_viewport()

## CONSTRAIN WINDOW MOVEMENT
## Clamp the position so that the window doesn't go off the screen
## NOTE: Deals with local position
func constrain_position(point: Vector2, min_point: Vector2, max_point: Vector2) -> Vector2:
	var final_point := Vector2.ZERO
	if point.x < min_point.x:
		final_point.x = min_point.x
	elif (point.x + size.x) > max_point.x:
		final_point.x = max_point.x - size.x
	else:
		final_point.x = point.x
	
	if point.y < min_point.y:
		final_point.y = min_point.y
	elif (point.y + size.y) > max_point.y:
		final_point.y = max_point.y - size.y
	else:
		final_point.y = point.y
	
	return final_point

## Does the constraining to the viewport size, centered about (0,0) local position
func constrain_to_viewport() -> void:
	position = constrain_position(position, get_viewport_rect().size / -2.0, get_viewport_rect().size / 2.0)
	target_pos = constrain_position(target_pos, get_viewport_rect().size / -2.0, get_viewport_rect().size / 2.0)

func center_window_to(local_pos: Vector2) -> void:
	position = Vector2(local_pos.x - (size.x / 2.0), local_pos.y - (size.y / 2.0))
	target_pos = position
	constrain_to_viewport()

#endregion

#region WINDOW MANAGEMENT HANDLERS -> CALLED FROM DESKTOP

## WARNING: DO NOT CALL THESE DIRECTLY
## Handlers called when the specified operation is performed through the Desktop

func open_self() -> void:
	window_index = 0
	is_active = true
	opened.emit()
	
	move_to_front()
	
	## TODO: Opening animation

func bring_self_to_front() -> void:
	window_index = 0
	is_active = true
	brought_to_front.emit(true)
	
	move_to_front()
	
	## TODO: Bringing to front animation

func shift_self_back(new_index: int) -> void:
	window_index = new_index
	is_active = false
	shifted_back.emit()
	
	## TODO: Sending self back animation

func shift_self_forward(new_index: int) -> void:
	window_index = new_index
	shifted_forward.emit()
	if window_index == 0:
		is_active = true
		brought_to_front.emit(false)
		move_to_front()
	
	## TODO: Shift forward/brought to front animation

func close_self() -> void:
	## CLOSE THIS WINDOW
	is_active = false
	is_closing = true
	all_clear_for_queue_free = true
	closed.emit() # NOTE: Some things from the signal may change all_clear_for_queue_free
	
	close()

#endregion
