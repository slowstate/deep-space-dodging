extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var shield_bar: ColorRect = $UI/ShieldBar
@onready var shield_bar_meter: ColorRect = $UI/ShieldBar/ShieldBarMeter
@onready var encounter_timer: Timer = $EncounterTimer
@onready var playable_area: CollisionShape2D = $PlayableBoundary/PlayableArea
@onready var attack_timer: Timer = $AttackTimer
@onready var unknown_ship: Sprite2D = $UnknownShip
@onready var unknown_ship_move_timer: Timer = $UnknownShipMoveTimer
@onready var poseidon_stab_attack: Node2D = $PoseidonStabAttack
@onready var unknown_ship_grab_timer: Timer = $UnknownShipGrabTimer
@onready var unknown_ship_grab_move_timer: Timer = $UnknownShipGrabMoveTimer
@onready var fog_shader: ColorRect = $FogShader
@onready var fog_shader_fade_in_timer: Timer = $FogShaderFadeInTimer
@onready var fog_and_attack_fade_out_timer: Timer = $FogAndAttackFadeOutTimer
@onready var encounter_fade_out_timer: Timer = $EncounterFadeOutTimer
@onready var player_move_timer: Timer = $PlayerMoveTimer
@onready var fade_out_victory_timer: Timer = $FadeOutVictoryTimer
@onready var fade_out_player_killed_timer: Timer = $FadeOutPlayerKilledTimer
@onready var stars_particles: GPUParticles2D = $StarsParticles
@onready var poseidon: Node2D = $Poseidon
@onready var stage_2_attack_timer: Timer = $Stage2AttackTimer

const POSEIDON_STAB_ATTACK = preload("res://Encounters/PoseidonEncounter/Poseidon/Attacks/Stab/poseidon_stab_attack.tscn")
const POSEIDON_SWEEP_ATTACK = preload("res://Encounters/PoseidonEncounter/Poseidon/Attacks/Sweep/poseidon_sweep_attack.tscn")
const POSEIDON_ASTEROID_ATTACK = preload("res://Encounters/PoseidonEncounter/Poseidon/Attacks/Asteroid/poseidon_asteroid_attack.tscn")
const MAELSTROM_BRIDGE = preload("res://Events/MaelstromBridge/maelstrom_bridge.tscn")
const PLAYER_KILLED = preload("res://Events/PlayerKilled/player_killed.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialog.dialog_complete.connect(on_dialog_complete)
	Dialog.play_dialog("poseidon introduction")
	shield_visible(false)
	poseidon_stab_attack.visible = false
	poseidon_stab_attack.process_mode = Node.PROCESS_MODE_DISABLED # The poseidon_stab_attack for the intro is an actual attack; this line pauses it until later
	AudioPlayer.play_sound("MaydayMusic", 10.0, 10.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Poseidon introduction animation
	if !unknown_ship_move_timer.is_stopped(): # Animation for moving the ship into the screen
		unknown_ship.position.y = 420 + (1 - pow(unknown_ship_move_timer.time_left/unknown_ship_move_timer.wait_time, 2))*150
		unknown_ship.modulate.a = (1 - pow(unknown_ship_move_timer.time_left/unknown_ship_move_timer.wait_time, 2))
	if !unknown_ship_grab_move_timer.is_stopped(): # Animation for moving the ship out of the screen
		unknown_ship.position.y = lerp(570, 370, 1.0 - unknown_ship_grab_move_timer.time_left/unknown_ship_grab_move_timer.wait_time)
		unknown_ship.modulate.a = unknown_ship_grab_move_timer.time_left/unknown_ship_grab_move_timer.wait_time
	
	# Poseidon victory animation
	if !fog_and_attack_fade_out_timer.is_stopped(): # Animation for moving the ship out of the screen
		for node in get_tree().get_nodes_in_group("attacks"):
			node.modulate.a = pow(fog_and_attack_fade_out_timer.time_left/fog_and_attack_fade_out_timer.wait_time, 3)
	if !encounter_fade_out_timer.is_stopped():
		var player_new_scale = lerp(1.0, 0.6, 1.0 - encounter_fade_out_timer.time_left/encounter_fade_out_timer.wait_time)
		player.scale = Vector2(player_new_scale, player_new_scale)
	if !player_move_timer.is_stopped():
		player.position.y -= (ease(1.0 - player_move_timer.time_left/player_move_timer.wait_time, 5.0)*10000)*delta
		AudioPlayer.get_sound("ThrustersSFX").volume_db = linear_to_db(1.0 - ease(1.0 - 	player_move_timer.time_left/player_move_timer.wait_time, 2.0))

	# Player shield meter logic
	shield_bar_meter.scale.x = float(player.current_shield)/float(player.MAX_SHIELD)
	match player.status:
		player.Statuses.None:
			shield_bar_meter.color = Color(0.227, 0.749, 0.122, 0.8)
		player.Statuses.HitImmune:
			shield_bar_meter.color = Color(1.0, 1.0, 1.0, 0.8)
		player.Statuses.ShieldRecharging:
			shield_bar_meter.color = Color(0.0, 0.7, 0.7, 0.8)

func on_dialog_complete(dialog_key: String):
	match dialog_key:
		"poseidon introduction":
			poseidon_stab_attack.visible = true
			poseidon_stab_attack.process_mode = Node.PROCESS_MODE_INHERIT # Resumes the poseidon_stab_attack animation
			unknown_ship_grab_timer.start() # This timer is to accommodate for the charge + stab time of the poseidon_stab_attack
			Dialog.play_dialog("poseidon encounter")
			await get_tree().create_timer(1).timeout # Plays the PlayerHitSFX after 0.9 seconds, when the unknown ship is grabbed 
			AudioPlayer.play_sound("PlayerHitSFX", -2.0, -2.0)
		"poseidon encounter":
			fog_shader_fade_in_timer.stop()
			fog_shader.set_opacity(1.0)
			poseidon.modulate.a = 1.0
			begin_spawning()
			shield_visible(true)
			encounter_timer.start() # Encounter time set on $EncounterTimer node
			AudioPlayer.stop_sound("MaydayMusic")
			AudioPlayer.play_sound("PoseidonMusic", 10.0, 10.0)
			stage_2_attack_timer.start()
		"player killed":
			fade_out_player_killed_timer.start()
			attack_timer.stop()


func _on_unknown_ship_grab_timer_timeout() -> void:
	unknown_ship_grab_move_timer.start()

func _on_encounter_timer_timeout() -> void:
	attack_timer.stop()
	player.enable_hitbox(false)
	player.enable_collision(false)
	player.enable_controls(false)
	player.stop_shield_recharge()
	shield_visible(false)
	fog_and_attack_fade_out_timer.start()

func _on_fog_fade_out_timer_timeout() -> void:
	if !player.is_killed:
		player.enable_thruster_particles(true, 0.3)
		AudioPlayer.play_sound("ThrustersSFX", -10.0, -10.0)
		encounter_fade_out_timer.start()
		var stars_p: ParticleProcessMaterial = stars_particles.process_material
		stars_p.radial_velocity_min = -15
		stars_p.radial_velocity_max = -10
		AudioPlayer.play_sound("RumblingSFX", 10.0, 10.0)
	
func _on_encounter_fade_out_timer_timeout() -> void:
	var stars_p: ParticleProcessMaterial = stars_particles.process_material
	stars_p.radial_velocity_min = 0
	stars_p.radial_velocity_max = 0
	player_move_timer.start()
	player.enable_thruster_particles(true, 1.0)
	AudioPlayer.stop_sound("RumblingSFX")
	
func _on_player_move_timer_timeout() -> void:
	fade_out_victory_timer.start()

func _on_fade_out_victory_timer_timeout() -> void:
	AudioPlayer.stop_sound("PoseidonMusic")
	AudioPlayer.stop_sound("ThrustersSFX")
	get_tree().change_scene_to_packed(MAELSTROM_BRIDGE)

func _on_player_killed() -> void:
	shield_visible(false)
	player.enable_hitbox(false)
	player.enable_collision(false)
	player.enable_controls(false)
	Dialog.play_dialog("player killed")

func _on_fade_out_player_killed_timer_timeout() -> void:
	get_tree().change_scene_to_packed(PLAYER_KILLED)


func shield_visible(enabled: bool):
	shield_bar.visible = enabled

func begin_spawning():
	attack_timer.wait_time = 0.05 # A miniscule wait time is required to start the attack_timer effective immediately
	attack_timer.start()


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

func _on_stage_2_attack_timer_timeout() -> void:
	spawn_stab_attack()
	spawn_stab_attack()
	spawn_stab_attack()
	spawn_stab_attack()
	spawn_stab_attack()
	
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
	add_child(new_stab_attack)

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
	add_child(new_sweep_attack)

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
	add_child(new_asteroid_attack)
