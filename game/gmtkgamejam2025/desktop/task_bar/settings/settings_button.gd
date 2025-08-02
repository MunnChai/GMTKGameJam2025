class_name SettingsButton
extends TextureButton

@onready var settings_panel: SettingsPanel = %SettingsPanel
@onready var settings_button_text: RichTextLabel = %SettingsButtonText

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	settings_panel.visible = !settings_panel.visible
	
	if settings_panel.visible:
		settings_button_text.add_theme_color_override("default_color", Color.WHITE)
	else:
		settings_button_text.add_theme_color_override("default_color", Color.BLACK)
