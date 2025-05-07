extends Node2D

@onready var fade_rect: ColorRect = $FadeRect
@onready var fade_timer: Timer = $FadeTimer

const OUTRO = preload("res://Events/Outro/outro.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialog.dialog_complete.connect(on_dialog_complete)
	Dialog.play_dialog("maelstrom bridge")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !fade_timer.is_stopped():
		fade_rect.color.a = 1-fade_timer.time_left/fade_timer.wait_time


func on_dialog_complete(dialog_key: String) -> void:
	match dialog_key:
		"maelstrom bridge":
			fade_timer.start()


func _on_fade_timer_timeout() -> void:
	get_tree().change_scene_to_packed(OUTRO)
