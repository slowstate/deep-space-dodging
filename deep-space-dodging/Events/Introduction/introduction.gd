extends Node2D

@onready var fade_rect: ColorRect = $FadeRect
@onready var fade_timer: Timer = $FadeTimer

const ENCOUNTER_POSEIDON = preload("res://Encounters/PoseidonEncounter/encounter_poseidon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_timer.start()
	Dialog.dialog_complete.connect(on_dialog_complete)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fade_rect.color.a = fade_timer.time_left/fade_timer.wait_time


func _on_fade_timer_timeout() -> void:
	Dialog.play_dialog("introduction")

func on_dialog_complete(dialog_key: String) -> void:
	match dialog_key:
		"introduction":
			get_tree().change_scene_to_packed(ENCOUNTER_POSEIDON)
