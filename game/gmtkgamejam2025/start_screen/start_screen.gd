class_name StartScreen
extends Node2D

@onready var start_button: Button = %StartButton
@onready var player_input: LineEdit = %UsernameInput

const DesktopScene = preload("res://desktop/desktop.tscn")

func _ready() -> void:
	player_input.text_submitted.connect(on_input_submitted)
	start_button.pressed.connect(on_start_pressed)

func _process(delta: float) -> void:
	if player_input.text != "":
		start_button.disabled = false
	
func on_input_submitted(text: String) -> void:
	on_start_pressed()
	
func on_start_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_basic_click")
	get_tree().change_scene_to_packed(DesktopScene)
	GameStateManager.set_username(player_input.text)
