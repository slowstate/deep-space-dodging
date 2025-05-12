extends Node2D

@onready var position_offset: Area2D = $PositionOffset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position_offset.rotation += deg_to_rad(randi_range(45, 60)*delta)
	if position_offset.rotation >= deg_to_rad(225):
		queue_free()
	
func set_position_offset(x: float, y: float):
	position_offset.position += Vector2(x, y)
