extends Node2D

var MAIN_MENU = load("res://Menus/main_menu.tscn")

func _on_killed_label_timer_timeout() -> void:
	AudioPlayer.stop_sound("PoseidonMusic")
	get_tree().change_scene_to_packed(MAIN_MENU)
