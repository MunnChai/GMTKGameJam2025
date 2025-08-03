class_name StartScreen
extends Node2D

@onready var start_button: TextureButton = %StartButton
@onready var username_input: LineEdit = %UsernameInput
@onready var password_input: LineEdit = %PasswordInput

const DesktopScene = preload("res://desktop/desktop.tscn")

var can_login: bool = false

func _ready() -> void:
	username_input.text_submitted.connect(on_input_submitted)
	password_input.text_submitted.connect(on_input_submitted)
	username_input.text_changed.connect(_on_text_changed)
	password_input.text_changed.connect(_on_text_changed)
	start_button.pressed.connect(on_start_pressed)

func _on_text_changed(new_text: String) -> void:
	if username_input.text == "" or password_input.text == "":
		disable_login_button()
	else:
		enable_login_button()

func disable_login_button() -> void:
	can_login = false
	start_button.disabled = true

func enable_login_button() -> void:
	can_login = true
	start_button.disabled = false

func on_input_submitted(text: String) -> void:
	on_start_pressed()
	
func on_start_pressed() -> void:
	if not can_login:
		return
	SoundManager.play_global_oneshot(&"ui_basic_click")
	get_tree().change_scene_to_packed(DesktopScene)
	GameStateManager.set_username(username_input.text)


func _on_password_input_text_changed(new_text: String) -> void:
	SoundManager.play_global_oneshot(&"ui_basic_click")


func _on_username_input_text_changed(new_text: String) -> void:
	SoundManager.play_global_oneshot(&"ui_basic_click")
