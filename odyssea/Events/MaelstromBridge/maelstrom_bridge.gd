extends Node2D

@onready var fade_in_timer: Timer = $FadeInTimer
@onready var fade_in_rect: ColorRect = $FadeInRect
@onready var fade_out_timer: Timer = $FadeOutTimer
@onready var fade_out_rect: ColorRect = $FadeOutRect
@onready var player: Sprite2D = $Player

const OUTRO = preload("res://Events/Outro/outro.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialog.dialog_complete.connect(on_dialog_complete)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !fade_in_timer.is_stopped():
		fade_in_rect.color.a = fade_in_timer.time_left/fade_in_timer.wait_time
	if !fade_out_timer.is_stopped():
		fade_out_rect.color.a = 1-fade_out_timer.time_left/fade_out_timer.wait_time
		player.position.y = 950 - ease(1 - fade_out_timer.time_left/fade_out_timer.wait_time, -3) * 400


func _on_fade_in_timer_timeout() -> void:
	Dialog.play_dialog("maelstrom bridge")

func on_dialog_complete(dialog_key: String) -> void:
	match dialog_key:
		"maelstrom bridge":
			fade_out_timer.start()

func _on_fade_out_timer_timeout() -> void:
	get_tree().change_scene_to_packed(OUTRO)
