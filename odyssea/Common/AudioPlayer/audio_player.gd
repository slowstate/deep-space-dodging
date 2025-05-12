extends Node2D

var Audio: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is AudioStreamPlayer2D:
			Audio[child.name] = child


func play_sound(audio_stream_string: String, volume_db_min: float = 0.0, volume_db_max: float = 0.0, pitch_scale_min: float = 1.0, pitch_scale_max: float = 1.0):
	var audio_stream = Audio.get(audio_stream_string)
	audio_stream.volume_db = volume_db_min
	audio_stream.volume_db = randf_range(volume_db_min, volume_db_max)
	audio_stream.pitch_scale = randf_range(pitch_scale_min, pitch_scale_max)
	audio_stream.play()

func get_sound(audio_stream_string: String) -> AudioStreamPlayer2D:
	return Audio.get(audio_stream_string)

func stop_sound(audio_stream_string: String):
	if Audio.has(audio_stream_string):
		Audio.get(audio_stream_string).stop()

func is_playing(audio_stream: String) -> bool:
	if Audio.has(audio_stream):
		return Audio.get(audio_stream).playing
	else:
		return false
