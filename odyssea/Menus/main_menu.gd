extends Node2D

@onready var chevron_label: Label = $MenuBox/ChevronLabel
@onready var chevron_timer: Timer = $MenuBox/ChevronTimer

const INTRODUCTION = preload("res://Events/Introduction/introduction.tscn")

enum MenuItem {BeginJourney, Exit}
var selectedMenuItem: MenuItem = MenuItem.BeginJourney

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.play_sound("SpaceMusic", 10.0, 10.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("player_move_up") || Input.is_action_just_pressed("player_move_down"):
		match selectedMenuItem:
			MenuItem.BeginJourney:
				AudioPlayer.play_sound("ButtonClickSFX", -10.0, -10.0, 4.0, 4.0)
				selectedMenuItem = MenuItem.Exit
				chevron_label.position.y = 135
			MenuItem.Exit:
				AudioPlayer.play_sound("ButtonClickSFX", -10.0, -10.0, 4.5, 4.5)
				selectedMenuItem = MenuItem.BeginJourney
				chevron_label.position.y = 95
		chevron_label.visible = true
		chevron_timer.start()
	
	if Input.is_action_just_pressed("player_accept"):
		match selectedMenuItem:
			MenuItem.BeginJourney:
				AudioPlayer.play_sound("ButtonClickSFX", -2.0, -2.0, 1.0, 1.01)
				get_tree().change_scene_to_packed(INTRODUCTION)
			MenuItem.Exit:
				get_tree().quit()


func _on_start_button_pressed() -> void:
	AudioPlayer.stop_sound("SpaceMusic")
	AudioPlayer.play_sound("ButtonClickSFX", -2.0, -2.0, 1.0, 1.01)
	get_tree().change_scene_to_packed(INTRODUCTION)


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_start_button_mouse_entered() -> void:
	AudioPlayer.play_sound("ButtonClickSFX", -10.0, -10.0, 4.5, 4.5)


func _on_exit_button_mouse_entered() -> void:
	AudioPlayer.play_sound("ButtonClickSFX", -10.0, -10.0, 4.0, 4.0)
