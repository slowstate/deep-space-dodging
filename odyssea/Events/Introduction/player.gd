extends Sprite2D

var player_original_position = position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x = player_original_position.x + sin(Time.get_unix_time_from_system()*50.0)*0.5
