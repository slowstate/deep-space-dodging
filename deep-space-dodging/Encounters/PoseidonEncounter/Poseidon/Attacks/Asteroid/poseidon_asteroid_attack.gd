extends RigidBody2D

@onready var despawn_timer: Timer = $DespawnTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	angular_velocity = deg_to_rad(randi_range(30, 45))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	modulate.a = pow((despawn_timer.time_left*3)/despawn_timer.wait_time, 3.0)


func _on_despawn_timer_timeout() -> void:
	queue_free()
