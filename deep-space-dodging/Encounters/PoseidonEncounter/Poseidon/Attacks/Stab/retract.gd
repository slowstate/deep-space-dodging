class_name Retract extends State

@onready var sprite_2d: Sprite2D = $"../../Sprite2D"
@onready var collision_polygon_2d: CollisionPolygon2D = $"../../CollisionPolygon2D"

signal retracted

var speed = 50

func physics_update(delta: float) -> void:
	if sprite_2d.position.y < 0:
		sprite_2d.position.y += speed * delta
		collision_polygon_2d.position.y += speed * delta
	else:
		retracted.emit()
