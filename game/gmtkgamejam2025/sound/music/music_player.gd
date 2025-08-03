class_name MusicPlayer
extends AudioStreamPlayer

@export var music_list: Array[AudioStream]

var i = 0

func _ready() -> void:
	do_play()
	finished.connect(_on_finished)

func do_play() -> void:
	stream = music_list[i]
	play()
	i += 1
	i %= music_list.size()

func _on_finished() -> void:
	await get_tree().create_timer(5.0).timeout
	do_play()

func fade_out(dur: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "volume_linear", 0.0, 2.0)
