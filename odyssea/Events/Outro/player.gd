extends Sprite2D

var player_original_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position.x = player_original_position.x + sin(Time.get_unix_time_from_system()*50.0)*0.5
