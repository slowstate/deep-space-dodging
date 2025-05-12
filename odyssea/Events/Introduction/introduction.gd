extends Node2D

@onready var fade_in_rect: ColorRect = $FadeInRect
@onready var fade_in_timer: Timer = $FadeInTimer
@onready var fade_out_rect: ColorRect = $FadeOutRect
@onready var fade_out_timer: Timer = $FadeOutTimer

const ENCOUNTER_POSEIDON = preload("res://Encounters/PoseidonEncounter/encounter_poseidon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.play_sound("VoidMusic", 10.0, 10.0)
	AudioPlayer.play_sound("SpaceAmbienceSFX")
	fade_in_timer.start()
	Dialog.dialog_complete.connect(on_dialog_complete)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !fade_in_timer.is_stopped():
		fade_in_rect.color.a = fade_in_timer.time_left/fade_in_timer.wait_time
	if !fade_out_timer.is_stopped():
		fade_out_rect.color.a = 1-fade_out_timer.time_left/fade_out_timer.wait_time


func _on_fade_in_timer_timeout() -> void:
	Dialog.play_dialog("introduction")


func on_dialog_complete(dialog_key: String) -> void:
	match dialog_key:
		"introduction":
			fade_out_timer.start()


func _on_fade_out_timer_timeout() -> void:
	AudioPlayer.stop_sound("VoidMusic")
	get_tree().change_scene_to_packed(ENCOUNTER_POSEIDON)
