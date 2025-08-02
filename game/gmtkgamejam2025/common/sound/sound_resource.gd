class_name SoundResource
extends Resource

## ---
## SOUND RESOURCE
## A resource representing a sound with an id
## ---

@export var id: StringName # ID for this sound
@export var linear_volume: float = 1.0 # How loud?
@export var pitch_variation_range: float = 0.3 # Pitch variation (+/-)
@export var attenuation_override: float = -1.0 # If you want to avoid using default attenuation
@export var audio_streams: Array[AudioStream] # All audio streams associated with this sound

## Returns the audio stream at the index, clamped to array bounds
func get_audio_stream(index: int = 0) -> AudioStream:
	index = clampi(index, 0, audio_streams.size() - 1)
	return audio_streams[index]

## Returns a equally weighted random audio stream from all options
func get_random_audio_stream() -> AudioStream:
	return audio_streams.pick_random()
