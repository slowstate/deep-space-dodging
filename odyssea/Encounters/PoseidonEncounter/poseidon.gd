extends Node2D

@onready var fog_shader_fade_in_timer: Timer = $"../FogShaderFadeInTimer"
@onready var encounter_fade_out_timer: Timer = $"../EncounterFadeOutTimer"

var original_position = position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !fog_shader_fade_in_timer.is_stopped():
		modulate.a = pow(1.0-fog_shader_fade_in_timer.time_left/fog_shader_fade_in_timer.wait_time, 5)
	if !encounter_fade_out_timer.is_stopped():
		var new_scale = 1.5 - ease(1.0 - encounter_fade_out_timer.time_left/encounter_fade_out_timer.wait_time, -2.0)*0.9 #lerp(1.5, 0.6, pow(1.0 - encounter_fade_out_timer.time_left/encounter_fade_out_timer.wait_time, 5))
		scale = Vector2(new_scale, new_scale)
		position.x = original_position.x + sin(Time.get_unix_time_from_system()*100.0)*(encounter_fade_out_timer.time_left/encounter_fade_out_timer.wait_time)*5.0
