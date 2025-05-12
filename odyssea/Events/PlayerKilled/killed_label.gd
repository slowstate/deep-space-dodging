extends Label

@onready var killed_label_timer: Timer = $"../KilledLabelTimer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !killed_label_timer.is_stopped():
		label_settings.font_color.a = 1 - killed_label_timer.time_left/killed_label_timer.wait_time
