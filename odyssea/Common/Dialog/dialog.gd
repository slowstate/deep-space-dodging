extends Area2D

@onready var dialog_background: ColorRect = $DialogBackground
@onready var dialog_label: Label = $DialogLabel
@onready var letter_by_letter_timer: Timer = $LetterByLetterTimer
@onready var ellipses_label: Label = $EllipsesLabel

signal dialog_complete(dialog_key: String)

var t := 0.0

var current_dialog_key = "" # Keys can be found in res://Common/Dialog/dialog_db.json
var current_dialog_sequence = [] # An array of all dialog lines for a key
var current_dialog_line = "" # A single dialog line

const DIALOG_DB = preload("res://Common/Dialog/dialog_db.json")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("player_accept") || Input.is_action_just_pressed("player_mouse_accept"):
		if current_dialog_key != "":
			AudioPlayer.play_sound("ButtonClickSFX", -2.0, -2.0, 1.0, 1.01)
			if dialog_label.visible_characters < current_dialog_line.length(): # If displaying letter by letter then skip
				dialog_label.visible_characters = current_dialog_line.length()
			elif current_dialog_sequence.size() > 0: #  If lines still left to display then display next line
				current_dialog_line = current_dialog_sequence.pop_front()
				dialog_label.visible_characters = 0
				dialog_label.text = current_dialog_line
				AudioPlayer.play_sound("TextSFX")
			else: # If no lines left to display then close dialog
				var completed_dialog_key = current_dialog_key
				current_dialog_key = ""
				visible = false
				dialog_complete.emit(completed_dialog_key)
	
	t += delta
	if t >= 0.01: # Display a character every 10 ms
		if dialog_label.visible_characters < current_dialog_line.length():
			if current_dialog_line.contains("\""): dialog_label.label_settings.font_color = Color.WHITE
			else: dialog_label.label_settings.font_color = Color(0.227, 0.749, 0.122)
			dialog_label.visible_characters += 1
			t = 0.0
			ellipses_label.visible = false
		else:
			AudioPlayer.stop_sound("TextSFX")
			ellipses_label.visible = true

func play_dialog(dialog_key: String):
	AudioPlayer.play_sound("TextSFX")
	current_dialog_key = dialog_key
	current_dialog_sequence = DIALOG_DB.data[current_dialog_key].duplicate()
	current_dialog_line = current_dialog_sequence.pop_front()
	dialog_label.visible_characters = 0
	dialog_label.text = current_dialog_line
	ellipses_label.visible = false
	visible = true
	
