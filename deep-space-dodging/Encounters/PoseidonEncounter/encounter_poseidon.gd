extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var shield_label: Label = $UI/ShieldLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shield_label.text = str(player.current_shield) + "🛡️"
