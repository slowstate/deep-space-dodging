extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hit_timer: Timer = $HitTimer
@onready var shield_recharge_start_timer: Timer = $ShieldRechargeStartTimer
@onready var shield_recharge_timer: Timer = $ShieldRechargeTimer
@onready var collision_box: CollisionPolygon2D = $CollisionBox
@onready var player_hit_sfx: AudioStreamPlayer2D = $PlayerHitSFX

signal killed

enum Statuses {None, HitImmune, ShieldRecharging}
var status: Statuses = Statuses.None
const MOVE_SPEED = 30000.0
const JUMP_VELOCITY = -400.0

const MAX_SHIELD = 5
var current_shield = MAX_SHIELD
var hitbox_enabled = true
var controls_enabled = true

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if !hit_timer.is_stopped():
		sprite_2d.visible = true if roundi(hit_timer.time_left*10) % 2 == 0 else false
	
	rotation = deg_to_rad(0)
	
	if controls_enabled:
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


func _on_hit_box_area_entered(area: Area2D) -> void:
	if !hitbox_enabled: return
	if !hit_timer.is_stopped():
		return
	
	if current_shield <= 0:
		killed.emit()
	
	player_hit_sfx.play()
	current_shield -= 1
	
	hit_timer.wait_time = 2
	hit_timer.start()
	status = Statuses.HitImmune
	
	shield_recharge_timer.stop()
	
	shield_recharge_start_timer.wait_time = 5
	shield_recharge_start_timer.start()


func _on_shield_recharge_start_timer_timeout() -> void:
	status = Statuses.ShieldRecharging
	current_shield +=1
	shield_recharge_timer.wait_time = 1
	shield_recharge_timer.start()


func _on_shield_recharge_timer_timeout() -> void:
	if current_shield >= MAX_SHIELD: status = Statuses.None
	else:
		current_shield +=1
		shield_recharge_timer.wait_time = 1
		shield_recharge_timer.start()


func _on_hit_timer_timeout() -> void:
	status = Statuses.None

func enable_hitbox(is_enabled: bool):
	hitbox_enabled = is_enabled

func enable_collision(is_enabled: bool):
	collision_box.disabled = !is_enabled

func enable_controls(is_enabled: bool):
	controls_enabled = is_enabled
