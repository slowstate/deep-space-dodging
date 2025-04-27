class_name Charge extends State

@onready var sprite_2d: Sprite2D = $"../../Sprite2D"
@onready var collision_polygon_2d: CollisionPolygon2D = $"../../CollisionPolygon2D"

var speed = 30

func physics_update(delta: float) -> void:
	if sprite_2d.position.y > -30:
		sprite_2d.position.y -= speed * delta
		collision_polygon_2d.position.y -= speed * delta
	else:
		transition.emit("Stab")
