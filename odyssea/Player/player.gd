extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hit_timer: Timer = $HitTimer
@onready var hit_stun_timer: Timer = $HitStunTimer
@onready var shield_recharge_start_timer: Timer = $ShieldRechargeStartTimer
@onready var shield_recharge_timer: Timer = $ShieldRechargeTimer
@onready var collision_box: CollisionPolygon2D = $CollisionBox

@onready var explosion_particles: GPUParticles2D = $ExplosionParticles
@onready var orange_spark_particles: GPUParticles2D = $OrangeSparkParticles
@onready var yellow_spark_particles: GPUParticles2D = $YellowSparkParticles
@onready var thruster_left_particles: GPUParticles2D = $ThrusterLeftParticles
@onready var thruster_right_particles: GPUParticles2D = $ThrusterRightParticles

signal killed

enum Statuses {None, HitImmune, ShieldRecharging}
var status: Statuses = Statuses.None
const MOVE_SPEED = 25000.0
const JUMP_VELOCITY = -400.0

const MAX_SHIELD = 5
var current_shield = MAX_SHIELD
var hitbox_enabled = true
var controls_enabled = true
var shield_recharge_enabled = true
var is_killed = false
var original_position = position
var sprite_hitstun_gradient: GradientTexture1D

func _ready() -> void:
	sprite_hitstun_gradient = sprite_2d.material.get_shader_parameter("mask_gradient")
	sprite_hitstun_gradient.gradient.set_color(0, Color.WHITE)
	explosion_particles.visible = false
	orange_spark_particles.visible = false
	yellow_spark_particles.visible = false
	thruster_left_particles.visible = false
	thruster_right_particles.visible = false

func _physics_process(delta: float) -> void:
	rotation = deg_to_rad(0)
	if !hit_timer.is_stopped():
		sprite_2d.visible = true if roundi(hit_timer.time_left*10) % 2 == 0 else false
	if is_killed:
		position.x = original_position.x + sin(Time.get_unix_time_from_system()*100.0)*1.0
		position.x = original_position.x + sin(Time.get_unix_time_from_system()*100.0)
		rotation = deg_to_rad(sin(Time.get_unix_time_from_system()*2.0)*5.0)
	
	if controls_enabled && hit_stun_timer.is_stopped():
		var move_vec = Vector2()
		if Input.is_action_pressed("player_move_up"):
			move_vec.y -= 1
		if Input.is_action_pressed("player_move_left"):
			move_vec.x -= 1
			rotation = deg_to_rad(-5)
		if Input.is_action_pressed("player_move_down"):
			move_vec.y += 1
		if Input.is_action_pressed("player_move_right"):
			move_vec.x += 1
			rotation = deg_to_rad(5)
		move_vec = move_vec.normalized()
		
		velocity = move_vec * MOVE_SPEED * delta
	else: velocity = Vector2(0.0, 0.0)

	move_and_slide()


func _on_hit_box_area_entered(_area: Area2D) -> void:
	if !hitbox_enabled: return
	if !hit_timer.is_stopped():
		return
	
	if current_shield <= 0:
		AudioPlayer.play_sound("ExplosionSFX", 10.0, 10.0)
		sprite_hitstun_gradient.gradient.set_color(0, Color.RED)
		killed.emit()
		original_position = position
		is_killed = true
		explosion_particles.visible = true
		orange_spark_particles.visible = true
		yellow_spark_particles.visible = true
		shield_recharge_start_timer.stop()
		shield_recharge_timer.stop()
	else:
		AudioPlayer.play_sound("PlayerHitSFX", -5.0, -5.0, 0.9, 1.1)
		current_shield -= 1
		
		sprite_hitstun_gradient.gradient.set_color(0, Color.RED)
		hit_stun_timer.start(0.1)
		hit_timer.start(2)
		status = Statuses.HitImmune
		
		shield_recharge_timer.stop()

func _on_hit_timer_timeout() -> void:
	if shield_recharge_enabled:
		status = Statuses.None
		
		if current_shield > 0:
			sprite_hitstun_gradient.gradient.set_color(0, Color.WHITE)
		else:
			sprite_hitstun_gradient.gradient.set_color(0, Color.ORANGE)

		shield_recharge_start_timer.start(5)
	
func _on_shield_recharge_start_timer_timeout() -> void:
	if shield_recharge_enabled:
		status = Statuses.ShieldRecharging
		sprite_hitstun_gradient.gradient.set_color(0, Color.LIGHT_SKY_BLUE)
		current_shield +=1
		shield_recharge_timer.start(1)


func _on_shield_recharge_timer_timeout() -> void:
	if shield_recharge_enabled:
		if current_shield >= MAX_SHIELD:
			status = Statuses.None
			sprite_hitstun_gradient.gradient.set_color(0, Color.WHITE)
		else:
			current_shield +=1
			shield_recharge_timer.start(1)


func enable_hitbox(is_enabled: bool):
	hitbox_enabled = is_enabled

func enable_collision(is_enabled: bool):
	collision_box.call_deferred("set_disabled", !is_enabled)

func enable_controls(is_enabled: bool):
	controls_enabled = is_enabled

func stop_shield_recharge():
	shield_recharge_enabled = false
	shield_recharge_start_timer.stop()
	shield_recharge_timer.stop()

func enable_thruster_particles(is_enabled: bool, particle_amount_ratio: float = 1.0):
	particle_amount_ratio = clamp(particle_amount_ratio, 0.0, 1.0)
	thruster_left_particles.amount_ratio = particle_amount_ratio
	thruster_right_particles.amount_ratio = particle_amount_ratio
	var asdf: ParticleProcessMaterial = thruster_left_particles.process_material
	asdf.initial_velocity_max = 100.0 - 70.0 * particle_amount_ratio
	thruster_left_particles.call_deferred("set_visible",is_enabled)
	thruster_right_particles.call_deferred("set_visible",is_enabled)
