class_name Stab extends State

@onready var sprite_2d: Sprite2D = $"../../Sprite2D"
@onready var collision_polygon_2d: CollisionPolygon2D = $"../../CollisionPolygon2D"

var speed = 1200

func enter() -> void:
	pass
	#AudioPlayer.play_sound("StabSFX", -10.0, -5.0, 0.8, 1.2)

func physics_update(delta: float) -> void:
	if sprite_2d.position.y > -150:
		sprite_2d.position.y -= speed * delta
		collision_polygon_2d.position.y -= speed * delta
	else:
		transition.emit("Retract")
