class_name SoundManagerGlobal
extends Node

## ---
## SOUND MANAGER (AUTOLOAD SINGLETON)
## NOTE: Remember to create a scene, attach this script, set exports, and add to autoload!
## A singleton that handles 2D sound management and registration of sound effects
## ---
## NOTE: Requires DataUtil for loading resources
## ---
## TODO
## - Limit times per second the same track can be played
## - Audio player pooling
## ---

@export var default_attenuation := 8.0
@export var sfx_bus_id := &"SFX"

@export_category("Sound Resource Loading")
@export var log_loading := true 
@export var sfx_resource_path := "res://sound/sound_resources/"

@export_category("Custom Sound Players")
@export var custom_audio_stream_player: PackedScene = null ## Expected to be inherited from AudioStreamPlayer
@export var custom_audio_stream_player_2d: PackedScene = null ## Expected to be inherited from AudioStreamPlayer2D

var dict: Dictionary[StringName, SoundResource] = {}

func _ready() -> void:
	for sound: SoundResource in DataUtil.load_all_resources_in_folder(sfx_resource_path, "SoundResource", log_loading):
		dict.set(sound.id, sound)

## Get the SoundResource with the given id
## NOTE: SoundResources are loaded at boot time. 
## Make sure to restart the game when making changes to ids.
func get_sound(id: StringName) -> SoundResource:
	if not dict.has(id):
		print("WARNING! Attempting to play sound \"{id}\", but it is not registered. Did you make a typo/do you need to reload the game?".format({ "id": id }))
	return dict.get(id)

## Play a oneshot sound effect at the given global position (in 2D space)
## Automatically queue frees the player once finished
func play_oneshot(id: StringName, global_pos: Vector2) -> void:
	var audio_player := start_player(id, global_pos)
	
	if audio_player:
		await audio_player.finished
		audio_player.queue_free()

## Play a oneshot sound effect without any spatial sound adjustments
## Automatically queue frees the player once finished
func play_global_oneshot(id: StringName) -> void:
	var audio_player := start_global_player(id)
	
	if audio_player:
		await audio_player.finished
		audio_player.queue_free()

#region PLAYER INSTANTIATION

## Attempts to instantiate a sound player that is playing the given sound
## at the global position.
## If successful, returns the player node
func start_player(id: StringName, global_pos: Vector2) -> AudioStreamPlayer2D:
	var sound := get_sound(id)
	if not sound:
		return null
	var stream := sound.get_random_audio_stream()
	
	var audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new() if not custom_audio_stream_player_2d else custom_audio_stream_player_2d.instantiate()
	add_child(audio_player)
	
	## Set settings...
	audio_player.base_attenuation = default_attenuation
	if sound.attenuation_override >= 0.0:
		audio_player.base_attenuation = sound.attenuation_override
	audio_player.global_position = global_pos
	audio_player.stream = stream
	audio_player.pitch_scale = 1.0 + randf_range(-sound.pitch_variation_range, sound.pitch_variation_range)
	audio_player.base_volume = sound.linear_volume
	audio_player.bus = sfx_bus_id
	audio_player.play()
	
	return audio_player

## Attempts to instantiate a sound player that is playing the given sound
## with no particular position.
## If successful, returns the player node
func start_global_player(id: StringName, linear_volume: float = 0.7) -> AudioStreamPlayer:
	var sound := get_sound(id)
	if not sound:
		return null
	var stream := sound.get_random_audio_stream()
	
	## Set settings...
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new() if not custom_audio_stream_player else custom_audio_stream_player.instantiate()
	audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(audio_player)
	audio_player.stream = stream
	audio_player.pitch_scale = 1.0 + randf_range(-sound.pitch_variation_range, sound.pitch_variation_range)
	audio_player.volume_linear = linear_volume
	audio_player.bus = sfx_bus_id
	audio_player.play()
	
	return audio_player

#endregion
