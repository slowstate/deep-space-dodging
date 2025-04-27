extends Area2D

@onready var position_offset: Area2D = $PositionOffset

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position_offset.rotation += deg_to_rad(45*delta)
	if position_offset.rotation >= deg_to_rad(360):
		queue_free()
	
func set_position_offset(x: float, y: float):
	position_offset.position += Vector2(x, y)
