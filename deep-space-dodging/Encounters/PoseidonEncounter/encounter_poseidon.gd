extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var shield_label: Label = $UI/ShieldLabel
@onready var attack_spawner: Node2D = $AttackSpawner
@onready var encounter_timer: Timer = $EncounterTimer

const MAELSTROM_BRIDGE = preload("res://Events/MaelstromBridge/maelstrom_bridge.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialog.dialog_complete.connect(on_dialog_complete)
	Dialog.play_dialog("poseidon introduction")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shield_label.text = str(player.current_shield) + "🛡️"
	shield_label.label_settings.font_color = Color.WHITE
	match player.status:
		player.Statuses.None: shield_label.label_settings.font_color = Color.WHITE
		player.Statuses.HitImmune: shield_label.label_settings.font_color = Color.RED
		player.Statuses.ShieldRecharging: shield_label.label_settings.font_color = Color.BLUE

func on_dialog_complete(dialog_key: String):
	match dialog_key:
		"poseidon introduction":
			Dialog.play_dialog("poseidon encounter")
		"poseidon encounter":
			attack_spawner.begin_spawning()
			encounter_timer.start() # Encounter time set on $EncounterTimer node

func _on_encounter_timer_timeout() -> void:
	attack_spawner.stop_spawning_and_clear_attacks()
	get_tree().change_scene_to_packed(MAELSTROM_BRIDGE)
