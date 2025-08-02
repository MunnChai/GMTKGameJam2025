class_name SettingsPanel
extends PanelContainer

@onready var music_slider: HSlider = %MusicSlider
@onready var sound_slider: HSlider = %SoundSlider
@onready var reduced_motion_box: CheckBox = %ReducedMotionBox

const MUSIC_BUS := &"Music"
const SFX_BUS := &"SFX"

var ready_done := false

func _ready() -> void:
	music_slider.value_changed.connect(_on_music_value_changed)
	sound_slider.value_changed.connect(_on_sound_value_changed)
	reduced_motion_box.toggled.connect(_on_motion_box_checked)
	
	GameSettings.load_from_config()
	music_slider.value = GameSettings.get_setting("music_volume", 0.5, "audio")
	sound_slider.value = GameSettings.get_setting("sound_volume", 0.5, "audio")
	reduced_motion_box.button_pressed = GameSettings.get_setting("reduced_motion", false, "graphics")
	
	ready_done = true

func _on_music_value_changed(value: float) -> void:
	GameSettings.set_setting("music_volume", value, "audio")
	GameSettings.save_to_config()
	
	var bus_index = AudioServer.get_bus_index(MUSIC_BUS)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	if ready_done:
		SoundManager.play_global_oneshot(&"ui_basic_click")


func _on_sound_value_changed(value: float) -> void:
	GameSettings.set_setting("sound_volume", value, "audio")
	GameSettings.save_to_config()
	
	var bus_index = AudioServer.get_bus_index(SFX_BUS)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	if ready_done:
		SoundManager.play_global_oneshot(&"ui_basic_click")

func _on_motion_box_checked(is_toggled: bool) -> void:
	GameSettings.set_setting("reduced_motion", is_toggled, "graphics")
	GameSettings.save_to_config()
	
	if ready_done:
		SoundManager.play_global_oneshot(&"ui_basic_click")
