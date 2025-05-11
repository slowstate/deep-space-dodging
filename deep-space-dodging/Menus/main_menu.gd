extends Node2D

@onready var chevron_label: Label = $MenuBox/ChevronLabel
@onready var chevron_timer: Timer = $MenuBox/ChevronTimer

const INTRODUCTION = preload("res://Events/Introduction/introduction.tscn")

enum MenuItem {BeginJourney, Exit}
var selectedMenuItem: MenuItem = MenuItem.BeginJourney

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("player_move_up") || Input.is_action_just_pressed("player_move_down"):
		match selectedMenuItem:
			MenuItem.BeginJourney:
				selectedMenuItem = MenuItem.Exit
				chevron_label.position.y = 135
			MenuItem.Exit:
				selectedMenuItem = MenuItem.BeginJourney
				chevron_label.position.y = 95
		chevron_label.visible = true
		chevron_timer.start()
	
	if Input.is_action_just_pressed("player_accept"):
		match selectedMenuItem:
			MenuItem.BeginJourney:
				get_tree().change_scene_to_packed(INTRODUCTION)
			MenuItem.Exit:
				get_tree().quit()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(INTRODUCTION)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
