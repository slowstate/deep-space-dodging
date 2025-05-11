extends ColorRect

@onready var fade_out_victory_timer: Timer = $"../FadeOutVictoryTimer"
@onready var fade_out_player_killed_timer: Timer = $"../FadeOutPlayerKilledTimer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !fade_out_victory_timer.is_stopped():
		color.a = 1-fade_out_victory_timer.time_left/fade_out_victory_timer.wait_time
	if !fade_out_player_killed_timer.is_stopped():
		color.a = 1-fade_out_player_killed_timer.time_left/fade_out_player_killed_timer.wait_time
