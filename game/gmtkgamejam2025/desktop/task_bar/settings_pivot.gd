extends Control

@onready var pos := position

func _ready() -> void:
	position = pos + Vector2.DOWN * 280.0

func open() -> void:
	visible = true
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		position = pos
		return
	TweenUtil.whoosh(self, pos, 0.3)
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.4)

func close() -> void:
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		position = pos + Vector2.DOWN * 280.0
		return
	TweenUtil.whoosh(self, pos + Vector2.DOWN * 280.0, 0.3)
	#TweenUtil.pop_delta(self, Vector2(-0.3, 0), 0.4)
