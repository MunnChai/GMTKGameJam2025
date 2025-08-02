class_name SettingsButton
extends TextureButton

@onready var settings_panel: SettingsPanel = %SettingsPanel
@onready var settings_button_text: RichTextLabel = %SettingsButtonText

var is_open := true

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	is_open = !is_open
	
	#settings_panel.visible = !settings_panel.visible
	
	if is_open:
		settings_button_text.add_theme_color_override("default_color", Color.WHITE)
		%SettingsPivot.open()
	else:
		settings_button_text.add_theme_color_override("default_color", Color.BLACK)
		%SettingsPivot.close()
