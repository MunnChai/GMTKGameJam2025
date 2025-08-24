class_name Cutscene
extends CanvasLayer

@onready var fade: ColorRect = %Fade
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var next_scene: PackedScene

func _ready() -> void:
	fade.visible = true
	fade.modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade, "modulate:a", 0.0, 1.0)
	await tween.finished
	fade.visible = false
	
	animation_player.play("cutscene")

func transition_to_next_scene() -> void:
	fade.visible = true
	fade.modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	get_tree().change_scene_to_packed(next_scene)
