class_name SettingsButton
extends TextureButton

@onready var settings_panel: SettingsPanel = %SettingsPanel

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	settings_panel.visible = !settings_panel.visible
