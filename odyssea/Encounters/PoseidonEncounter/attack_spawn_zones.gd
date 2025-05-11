extends Node2D

# TODO: Move this to main script if this node is redundant
@onready var playable_area: CollisionShape2D = $"../PlayableBoundary/PlayableArea"
@onready var attack_timer: Timer = $"../AttackTimer"
@onready var encounter_timer: Timer = $"../EncounterTimer"

const POSEIDON_STAB_ATTACK = preload("res://Encounters/PoseidonEncounter/Poseidon/Attacks/Stab/poseidon_stab_attack.tscn")
const POSEIDON_SWEEP_ATTACK = preload("res://Encounters/PoseidonEncounter/Poseidon/Attacks/Sweep/poseidon_sweep_attack.tscn")
const POSEIDON_ASTEROID_ATTACK = preload("res://Encounters/PoseidonEncounter/Poseidon/Attacks/Asteroid/poseidon_asteroid_attack.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func begin_spawning():
	attack_timer.wait_time = 0.05 # A miniscule wait time is required to start the attack_timer effective immediately
	attack_timer.start()

func stop_spawning_and_clear_attacks():
	attack_timer.stop()
	for node in get_tree().get_nodes_in_group("attacks"):
		node.queue_free()

func random_spawn_location(attack_spawn_zone: CollisionShape2D) -> Vector2:
	var spawn_x_max = attack_spawn_zone.global_position.x + attack_spawn_zone.shape.get_rect().size.x/2
	var spawn_x_min = attack_spawn_zone.global_position.x - attack_spawn_zone.shape.get_rect().size.x/2
	var spawn_y_min = attack_spawn_zone.global_position.y - attack_spawn_zone.shape.get_rect().size.y/2
	var spawn_y_max = attack_spawn_zone.global_position.y + attack_spawn_zone.shape.get_rect().size.y/2
	var spawn_location = Vector2(randi_range(spawn_x_min, spawn_x_max), randi_range(spawn_y_min, spawn_y_max))
	return spawn_location

func _on_attack_timer_timeout() -> void:
	# TODO: Improve random attack pattern
	spawn_asteroid_attack()
	var encounter_progress = encounter_timer.time_left/encounter_timer.wait_time
	if encounter_progress > 0.5: # First half = easy
		spawn_random_attack()
		attack_timer.wait_time = randf_range(1.5, 2.0)
	elif encounter_progress < 0.5 && encounter_progress > 0.25: # Second to last quarter = moderate
		spawn_random_attack()
		attack_timer.wait_time = randf_range(1.0, 1.5)
	else: # Last quarter = hard
		attack_timer.wait_time = 1.0
		spawn_random_attack()
		spawn_random_attack()
	attack_timer.start()


func spawn_random_attack():
	match randi_range(0,2):
		0: spawn_stab_attack()
		1: spawn_sweep_attack()
		2: spawn_asteroid_attack()


func spawn_stab_attack():
	var new_stab_attack = POSEIDON_STAB_ATTACK.instantiate()
	
	# Pick a random position within the playable area
	var spawn_position = random_spawn_location(playable_area)
	
	# Set X or Y to the position of a random edge of the playable area
	match randi_range(0,3):
		0: spawn_position.x = playable_area.global_position.x + playable_area.shape.get_rect().size.x/2 # Right
		1: spawn_position.y = playable_area.global_position.y + playable_area.shape.get_rect().size.y/2 # Bottom
		2: spawn_position.x = playable_area.global_position.x - playable_area.shape.get_rect().size.x/2 # Left
		3: spawn_position.y = playable_area.global_position.y - playable_area.shape.get_rect().size.y/2 # Top
	new_stab_attack.position = spawn_position
	
	# Set the angle of the tentacle towards the playable area
	var x_rotation = 0
	var y_rotation = 0
	if spawn_position.x >= playable_area.global_position.x + playable_area.shape.get_rect().size.x/2 - 50: x_rotation = 270
	if spawn_position.x <= playable_area.global_position.x - playable_area.shape.get_rect().size.x/2 + 50: x_rotation = 90
	if spawn_position.y >= playable_area.global_position.y + playable_area.shape.get_rect().size.y/2 - 50: y_rotation = 0
	if spawn_position.y <= playable_area.global_position.y - playable_area.shape.get_rect().size.y/2 + 50: y_rotation = 180
	if x_rotation > 0 && y_rotation > 0:
		new_stab_attack.rotation = deg_to_rad((x_rotation + y_rotation)/2.0)
	else: new_stab_attack.rotation = deg_to_rad(x_rotation + y_rotation)
	new_stab_attack.add_to_group("attacks")
	get_tree().root.add_child(new_stab_attack)

func spawn_sweep_attack():
	var new_sweep_attack = POSEIDON_SWEEP_ATTACK.instantiate()
	
	# Pick a random position within the playable area
	var spawn_position = random_spawn_location(playable_area)
	
	# Set X or Y to the position of a random edge of the playable area
	match randi_range(0,3):
		0: spawn_position.x = playable_area.global_position.x + playable_area.shape.get_rect().size.x/2 # Right
		1: spawn_position.y = playable_area.global_position.y + playable_area.shape.get_rect().size.y/2 # Bottom
		2: spawn_position.x = playable_area.global_position.x - playable_area.shape.get_rect().size.x/2 # Left
		3: spawn_position.y = playable_area.global_position.y - playable_area.shape.get_rect().size.y/2 # Top
	new_sweep_attack.position = spawn_position
	
	# Set the angle of the tentacle towards the playable area
	var x_rotation = 0
	var y_rotation = 0
	if spawn_position.x >= playable_area.global_position.x + playable_area.shape.get_rect().size.x/2 - 50: x_rotation = 270
	if spawn_position.x <= playable_area.global_position.x - playable_area.shape.get_rect().size.x/2 + 50: x_rotation = 90
	if spawn_position.y >= playable_area.global_position.y + playable_area.shape.get_rect().size.y/2 - 50: y_rotation = 0
	if spawn_position.y <= playable_area.global_position.y - playable_area.shape.get_rect().size.y/2 + 50: y_rotation = 180
	if x_rotation > 0 && y_rotation > 0:
		new_sweep_attack.rotation = deg_to_rad((x_rotation + y_rotation)/2.0)
	else: new_sweep_attack.rotation = deg_to_rad(x_rotation + y_rotation)
	new_sweep_attack.add_to_group("attacks")
	get_tree().root.add_child(new_sweep_attack)

func spawn_asteroid_attack():
	var new_asteroid_attack = POSEIDON_ASTEROID_ATTACK.instantiate()
	
	# Pick two random positions within the playable area
	var start_position = random_spawn_location(playable_area)
	var start_position_random_playable_area_edge = randi_range(0, 3)
	match start_position_random_playable_area_edge:
		0: start_position.x = playable_area.global_position.x + playable_area.shape.get_rect().size.x/2 + 52 # Right
		1: start_position.y = playable_area.global_position.y + playable_area.shape.get_rect().size.y/2 + 52 # Bottom
		2: start_position.x = playable_area.global_position.x - playable_area.shape.get_rect().size.x/2 - 52 # Left
		3: start_position.y = playable_area.global_position.y - playable_area.shape.get_rect().size.y/2 - 52 # Top
	
	var end_position = random_spawn_location(playable_area)
	var end_position_random_playable_area_edge = start_position_random_playable_area_edge
	while end_position_random_playable_area_edge == start_position_random_playable_area_edge:
		end_position_random_playable_area_edge = randi_range(0, 3)
	match end_position_random_playable_area_edge:
		0: end_position.x = playable_area.global_position.x + playable_area.shape.get_rect().size.x/2 + 52 # Right
		1: end_position.y = playable_area.global_position.y + playable_area.shape.get_rect().size.y/2 + 52 # Bottom
		2: end_position.x = playable_area.global_position.x - playable_area.shape.get_rect().size.x/2 - 52 # Left
		3: end_position.y = playable_area.global_position.y - playable_area.shape.get_rect().size.y/2 - 52 # Top
	
	new_asteroid_attack.position = start_position
	new_asteroid_attack.linear_velocity = (end_position - start_position).normalized() * 300
	new_asteroid_attack.add_to_group("attacks")
	get_tree().root.add_child(new_asteroid_attack)
