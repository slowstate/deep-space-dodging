extends Node2D

@onready var fade_in_timer: Timer = $FadeInTimer
@onready var fade_in_rect: ColorRect = $FadeInRect
@onready var fade_out_timer: Timer = $FadeOutTimer
@onready var fade_out_rect: ColorRect = $FadeOutRect
@onready var player: Sprite2D = $Player
@onready var thruster_left_particles: GPUParticles2D = $Player/ThrusterLeftParticles
@onready var thruster_right_particles: GPUParticles2D = $Player/ThrusterRightParticles

const OUTRO = preload("res://Events/Outro/outro.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thruster_left_particles.visible = false
	thruster_right_particles.visible = false
	Dialog.dialog_complete.connect(on_dialog_complete)
	AudioPlayer.play_sound("MaelstromMusic", 10.0, 10.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !fade_in_timer.is_stopped():
		fade_in_rect.color.a = 1.0 - ease(1 - fade_in_timer.time_left/fade_in_timer.wait_time, 0.3) 
	if !fade_out_timer.is_stopped():
		fade_out_rect.color.a = 1-fade_out_timer.time_left/fade_out_timer.wait_time
		player.position.y = 950 - ease(1 - fade_out_timer.time_left/fade_out_timer.wait_time, -3) * 400


func _on_fade_in_timer_timeout() -> void:
	Dialog.play_dialog("maelstrom bridge")

func on_dialog_complete(dialog_key: String) -> void:
	match dialog_key:
		"maelstrom bridge":
			fade_out_timer.start()
			thruster_left_particles.visible = true
			thruster_right_particles.visible = true

func _on_fade_out_timer_timeout() -> void:
	AudioPlayer.stop_sound("MaestromMusic")
	get_tree().change_scene_to_packed(OUTRO)
