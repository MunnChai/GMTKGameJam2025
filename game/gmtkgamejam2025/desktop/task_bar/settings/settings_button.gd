class_name SettingsButton
extends Button

@onready var settings_panel: SettingsPanel = %SettingsPanel
#@onready var settings_button_text: RichTextLabel = %SettingsButtonText
#@onready var settings_icon: TextureRect = %SettingsIcon

var is_open := false

func _ready() -> void:
	pivot_offset = size / 2.0
	
	pressed.connect(_on_pressed)
	
	GameStateManager.day_changed.connect(_on_day_changed)

func _on_day_changed(new_day: int) -> void:
	## Close the settings menu for the next day
	if is_open:
		toggle_open()
		button_pressed = false

func _on_pressed() -> void:
	if not GameSettings.get_setting("reduced_motion", false, "graphics"):
		TweenUtil.pop_delta(self, Vector2(0.2, 0.2), 0.3)
	
	SoundManager.play_global_oneshot(&"ui_basic_click")

	toggle_open()
	#settings_panel.visible = !settings_panel.visible

func toggle_open() -> void:
	is_open = !is_open
	
	if is_open:
		#settings_button_text.add_theme_color_override("default_color", Color.WHITE)
		#settings_icon.texture = load("res://assets/ui/icons/settings_icon_low_res_clicked.png")
		%SettingsPivot.open()
	else:
		#settings_button_text.add_theme_color_override("default_color", Color.BLACK)
		#settings_icon.texture = load("res://assets/ui/icons/settings_icon_low_res.png")
		%SettingsPivot.close()
