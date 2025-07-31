class_name JuicePivot
extends Control

## ---
## JUICE PIVOT
## Central pivot for DESKTOP WINDOWS
## Used for tweening from the center and other juicy things
## NOTE: Make sure to put content as a child of this node, 
## with this node at the center of the content
## ---

@export var window: DesktopWindow

func _ready() -> void:
	if not window:
		window = get_owner()
	
	window.opened.connect(_on_opened)
	window.brought_to_front.connect(_on_brought_to_front)
	window.shifted_forward.connect(_on_shifted_forward)
	window.shifted_back.connect(_on_shifted_back)
	window.closed.connect(_on_closed)
	
	window.drag_started.connect(_on_drag)
	window.drag_moved.connect(_on_drag_move)
	window.drag_released.connect(_on_drag_release)

func _on_opened() -> void:
	TweenUtil.pop_delta(self, Vector2(0.1, 0.1), 0.2)
func _on_brought_to_front(explicit: bool) -> void:
	if explicit: ## TODO: Only pop if there was something overlapping..?
		if not window.is_dragging:
			TweenUtil.pop_delta(self, Vector2(0.1, 0.1), 0.2)
func _on_shifted_forward() -> void:
	#TweenUtil.pop_delta(%CentralPivot, Vector2(0.1, 0.1))
	pass
func _on_shifted_back() -> void:
	#TweenUtil.pop_delta(%CentralPivot, Vector2(0.1, 0.1))
	pass
func _on_closed() -> void:
	window.all_clear_for_queue_free = false
	var tween := TweenUtil.scale_to(self, Vector2.ZERO, 0.15)
	await tween.finished
	window.all_clear_for_queue_free = true

func _on_drag() -> void:
	TweenUtil.scale_to(self, Vector2(1.05, 1.05), 0.1)

func _on_drag_move(delta: Vector2) -> void:
	pass

func _on_drag_release() -> void:
	TweenUtil.scale_to(self, Vector2(1.0, 1.0), 0.1)
