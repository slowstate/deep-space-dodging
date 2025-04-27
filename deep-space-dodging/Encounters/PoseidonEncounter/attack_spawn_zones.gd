extends Node2D

# TODO: Move this to main script if this node is redundant
@onready var playable_area: CollisionShape2D = $"../PlayableBoundary/PlayableArea"
@onready var attack_timer: Timer = $"../AttackTimer"

const POSEIDON_STAB_ATTACK = preload("res://Encounters/PoseidonEncounter/Poseidon/Attacks/Stab/poseidon_stab_attack.tscn")
const POSEIDON_SWEEP_ATTACK = preload("res://Encounters/PoseidonEncounter/Poseidon/Attacks/Sweep/poseidon_sweep_attack.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func random_spawn_location(attack_spawn_zone: CollisionShape2D) -> Vector2:
	var spawn_x_min = attack_spawn_zone.global_position.x - attack_spawn_zone.shape.get_rect().size.x/2
	var spawn_x_max = attack_spawn_zone.global_position.x + attack_spawn_zone.shape.get_rect().size.x/2
	var spawn_y_min = attack_spawn_zone.global_position.y - attack_spawn_zone.shape.get_rect().size.y/2
	var spawn_y_max = attack_spawn_zone.global_position.y + attack_spawn_zone.shape.get_rect().size.y/2
	var spawn_location = Vector2(randi_range(spawn_x_min, spawn_x_max), randi_range(spawn_y_min, spawn_y_max))
	return spawn_location

func _on_attack_timer_timeout() -> void:
	# TODO: Improve random attack pattern
	match randi_range(0,1):
		0: spawn_stab_attack()
		1: spawn_sweep_attack()
	attack_timer.wait_time = randi_range(2, 4)
	attack_timer.start()

func spawn_stab_attack():
	var new_stab_attack = POSEIDON_STAB_ATTACK.instantiate()
	var spawn_position = random_spawn_location(playable_area)
	match randi_range(0,3):
		0: spawn_position.x = playable_area.global_position.x + playable_area.shape.get_rect().size.x/2
		1: spawn_position.y = playable_area.global_position.y + playable_area.shape.get_rect().size.y/2
		2: spawn_position.x = playable_area.global_position.x - playable_area.shape.get_rect().size.x/2
		3: spawn_position.y = playable_area.global_position.y - playable_area.shape.get_rect().size.y/2
	new_stab_attack.position = spawn_position
	
	var x_rotation = 0
	var y_rotation = 0
	if spawn_position.x >= playable_area.global_position.x + playable_area.shape.get_rect().size.x/2 - 50: x_rotation = 270
	if spawn_position.x <= playable_area.global_position.x - playable_area.shape.get_rect().size.x/2 + 50: x_rotation = 90
	if spawn_position.y >= playable_area.global_position.y + playable_area.shape.get_rect().size.y/2 - 50: y_rotation = 0
	if spawn_position.y <= playable_area.global_position.y - playable_area.shape.get_rect().size.y/2 + 50: y_rotation = 180
	if x_rotation > 0 && y_rotation > 0:
		new_stab_attack.rotation = deg_to_rad((x_rotation + y_rotation)/2)
	else: new_stab_attack.rotation = deg_to_rad(x_rotation + y_rotation)
	get_tree().root.add_child(new_stab_attack)

func spawn_sweep_attack():
	var new_sweep_attack = POSEIDON_SWEEP_ATTACK.instantiate()
	
	var spawn_position = random_spawn_location(playable_area)
	match randi_range(0,3):
		0: spawn_position.x = playable_area.global_position.x + playable_area.shape.get_rect().size.x/2
		1: spawn_position.y = playable_area.global_position.y + playable_area.shape.get_rect().size.y/2
		2: spawn_position.x = playable_area.global_position.x - playable_area.shape.get_rect().size.x/2
		3: spawn_position.y = playable_area.global_position.y - playable_area.shape.get_rect().size.y/2
	new_sweep_attack.position = spawn_position
	
	var x_rotation = 0
	var y_rotation = 0
	if spawn_position.x >= playable_area.global_position.x + playable_area.shape.get_rect().size.x/2 - 50: x_rotation = 270
	if spawn_position.x <= playable_area.global_position.x - playable_area.shape.get_rect().size.x/2 + 50: x_rotation = 90
	if spawn_position.y >= playable_area.global_position.y + playable_area.shape.get_rect().size.y/2 - 50: y_rotation = 0
	if spawn_position.y <= playable_area.global_position.y - playable_area.shape.get_rect().size.y/2 + 50: y_rotation = 180
	if x_rotation > 0 && y_rotation > 0:
		new_sweep_attack.rotation = deg_to_rad((x_rotation + y_rotation)/2)
	else: new_sweep_attack.rotation = deg_to_rad(x_rotation + y_rotation)
	get_tree().root.add_child(new_sweep_attack)
