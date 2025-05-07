extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	angular_velocity = deg_to_rad(randi_range(30, 45))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_despawn_timer_timeout() -> void:
	queue_free()
