extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hit_timer: Timer = $HitTimer
@onready var shield_recharge_start_timer: Timer = $ShieldRechargeStartTimer
@onready var shield_recharge_timer: Timer = $ShieldRechargeTimer

const MOVE_SPEED = 30000.0
const JUMP_VELOCITY = -400.0

const MAX_SHIELD = 10
var current_shield = MAX_SHIELD

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if !hit_timer.is_stopped():
		sprite_2d.visible = true if roundi(hit_timer.time_left*10) % 2 == 0 else false
	
	var move_vec = Vector2()
	if Input.is_action_pressed("player_move_up"):
		move_vec.y -= 1
	if Input.is_action_pressed("player_move_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("player_move_down"):
		move_vec.y += 1
	if Input.is_action_pressed("player_move_right"):
		move_vec.x += 1
	move_vec = move_vec.normalized()
	
	velocity = move_vec * MOVE_SPEED * delta

	move_and_slide()


func _on_hit_box_area_entered(area: Area2D) -> void:
	if !hit_timer.is_stopped():
		return
	
	current_shield -= 1
	print("Shield hit: " + str(current_shield))
	
	hit_timer.wait_time = 2
	hit_timer.start()
	
	shield_recharge_timer.stop()
	
	shield_recharge_start_timer.wait_time = 5
	shield_recharge_start_timer.start()
	

func _on_shield_recharge_start_timer_timeout() -> void:
	shield_recharge_timer.wait_time = 1
	shield_recharge_timer.start()

func _on_shield_recharge_timer_timeout() -> void:
	current_shield +=1
	print("Shield recharge: " + str(current_shield))
	if current_shield < MAX_SHIELD:
		shield_recharge_timer.wait_time = 1
		shield_recharge_timer.start()
