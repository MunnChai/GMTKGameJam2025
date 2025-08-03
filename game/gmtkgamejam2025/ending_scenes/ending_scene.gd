extends CanvasLayer

@onready var close_button: TextureButton = %CloseButton
@onready var log_out_button: Button = %LogOutButton
@onready var fade: ColorRect = %Fade

const START_SCREEN = preload("res://start_screen/start_screen.tscn")

func _ready() -> void:
	close_button.pressed.connect(_on_button_pressed)
	log_out_button.pressed.connect(_on_button_pressed)
	
	fade.visible = true
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade, "modulate:a", 0.0, 1.0)
	await tween.finished
	fade.visible = false

func _on_button_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_basic_click")
	get_tree().change_scene_to_packed(START_SCREEN)
	GameStateManager.reset_game_state()
