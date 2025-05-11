extends ColorRect

@onready var fog_shader_fade_in_timer: Timer = $"../FogShaderFadeInTimer"
@onready var encounter_fade_out_timer: Timer = $"../EncounterFadeOutTimer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !fog_shader_fade_in_timer.is_stopped():
		material.set_shader_parameter("opacity", 1.0-fog_shader_fade_in_timer.time_left/fog_shader_fade_in_timer.wait_time)
	if !encounter_fade_out_timer.is_stopped():
		material.set_shader_parameter("opacity", encounter_fade_out_timer.time_left/encounter_fade_out_timer.wait_time)

func set_opacity(opacity: float):
	material.set_shader_parameter("opacity", opacity)
