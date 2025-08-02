class_name SettingsPanel
extends PanelContainer

@onready var music_slider: HSlider = %MusicSlider
@onready var sound_slider: HSlider = %SoundSlider
@onready var reduced_motion_box: CheckBox = %ReducedMotionBox

func _ready() -> void:
	music_slider.value_changed.connect(_on_music_value_changed)
	sound_slider.value_changed.connect(_on_sound_value_changed)
	reduced_motion_box.toggled.connect(_on_motion_box_checked)

func _on_music_value_changed(value: float) -> void:
	pass

func _on_sound_value_changed(value: float) -> void:
	pass

func _on_motion_box_checked(is_toggled: bool) -> void:
	pass
