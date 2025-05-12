extends Node2D

@onready var position_offset: Area2D = $PositionOffset

func _on_retract_retracted() -> void:
	queue_free()

func set_position_offset(x: float, y: float):
	position_offset.position += Vector2(x, y)
