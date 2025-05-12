extends ColorRect

@onready var fog_shader_fade_in_timer: Timer = $"../FogShaderFadeInTimer"
@onready var fog_and_attack_fade_out_timer: Timer = $"../FogAndAttackFadeOutTimer"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !fog_shader_fade_in_timer.is_stopped():
		material.set_shader_parameter("opacity", 1.0-fog_shader_fade_in_timer.time_left/fog_shader_fade_in_timer.wait_time)
	if !fog_and_attack_fade_out_timer.is_stopped():
		material.set_shader_parameter("opacity", fog_and_attack_fade_out_timer.time_left/fog_and_attack_fade_out_timer.wait_time)

func set_opacity(opacity: float):
	material.set_shader_parameter("opacity", opacity)
