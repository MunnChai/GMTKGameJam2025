class_name StartScreen
extends Node2D

@onready var start_button: Button = %StartButton

const DesktopScene = preload("res://desktop/desktop.tscn")

func _ready() -> void:
	start_button.pressed.connect(on_start_pressed)
	
func on_start_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_basic_click")
	get_tree().change_scene_to_packed(DesktopScene)
