class_name SettingsButton
extends Button

@onready var settings_panel: SettingsPanel = %SettingsPanel
#@onready var settings_button_text: RichTextLabel = %SettingsButtonText
#@onready var settings_icon: TextureRect = %SettingsIcon

var is_open := false

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	is_open = !is_open
	
	SoundManager.play_global_oneshot(&"ui_basic_click")

	
	#settings_panel.visible = !settings_panel.visible
	
	if is_open:
		#settings_button_text.add_theme_color_override("default_color", Color.WHITE)
		#settings_icon.texture = load("res://assets/ui/icons/settings_icon_low_res_clicked.png")
		%SettingsPivot.open()
	else:
		#settings_button_text.add_theme_color_override("default_color", Color.BLACK)
		#settings_icon.texture = load("res://assets/ui/icons/settings_icon_low_res.png")
		%SettingsPivot.close()
