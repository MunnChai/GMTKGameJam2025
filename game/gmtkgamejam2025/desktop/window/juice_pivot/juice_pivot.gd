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
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		return
	TweenUtil.pop_delta(self, Vector2(0.1, 0.1), 0.2)
	TweenUtil.whoosh(self, position, 0.25, Tween.TransitionType.TRANS_CUBIC, Tween.EaseType.EASE_OUT)
	position += Vector2.DOWN * 32.0
func _on_brought_to_front(explicit: bool) -> void:
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		return
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
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		window.all_clear_for_queue_free = true
		return
	window.all_clear_for_queue_free = false
	var tween := TweenUtil.scale_to(self, Vector2.ZERO, 0.15)
	TweenUtil.whoosh(self, position + Vector2.DOWN * 128.0, 0.15, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_IN)
	await tween.finished
	window.all_clear_for_queue_free = true

func _on_drag() -> void:
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		return
	TweenUtil.scale_to(self, Vector2(1.05, 1.05), 0.1)

var target_rot := rotation_degrees

func _on_drag_move(delta: Vector2) -> void:
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		return
	var amount := delta.x / 20.0
	target_rot -= amount

func _on_drag_release() -> void:
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		return
	TweenUtil.scale_to(self, Vector2(1.0, 1.0), 0.1)

func _process(delta: float) -> void:
	rotation_degrees = MathUtil.decay(rotation_degrees, target_rot, 15.0, delta)
	target_rot = MathUtil.decay(target_rot, 0.0, 15.0, delta)
