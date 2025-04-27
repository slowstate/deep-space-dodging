extends Area2D

@onready var position_offset: Area2D = $PositionOffset

enum Direction {left, down, right, up}
var direction: Direction


func setup() -> void:
	# TODO: Set up any variable config like damage, speed, etc.
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_retract_retracted() -> void:
	queue_free()

func set_position_offset(x: float, y: float):
	position_offset.position += Vector2(x, y)
