extends KinematicBody2D

# Global Vars
var MAX_SPEED = 0
var ACCEL = 10
var CURRENT_SPEED = MAX_SPEED
var YVEL = 0
var JUMP_POWER = -300
var ON_FLOOR = true
var GRAVITY = 9.8
var BOUNCE_DAMPENING = 1.5
var SPEED_PARTICLES = null
var SPEED_THRESHOLD = 500

#Signals
signal _on_points_gained(value)
signal _on_coins_gained(value)

var VELOCITY = Vector2(MAX_SPEED,0)

func _ready():
	$blink.play("al-blink")
	
	SPEED_PARTICLES = get_node("movement _particle")
	
	if SPEED_PARTICLES:
		SPEED_PARTICLES.emitting = false

func _physics_process(delta):
	_handle_input()
	_toggle_particles()

	#move and collide, bounce of certain objects vs 
	var collision = move_and_collide(VELOCITY * delta)
	if collision && collision.collider.is_in_group('bumper'):
		VELOCITY = VELOCITY.bounce(collision.normal) / BOUNCE_DAMPENING
		emit_signal("_on_points_gained", 1000)
	elif collision:
		VELOCITY = VELOCITY.slide(collision.normal)
		_decelerate(delta)
	else:
		_apply_gravity()

func _handle_input():
	if Input.is_action_just_pressed("ui_select") && ON_FLOOR:
		ON_FLOOR = false
		YVEL += JUMP_POWER

func _apply_gravity():
	VELOCITY.y += GRAVITY
	
func _accelerate(delta):
	if VELOCITY.x < MAX_SPEED:
		VELOCITY.x += (MAX_SPEED / ACCEL) * delta
		
func _decelerate(delta):
	if VELOCITY.x > 0:
		VELOCITY.x -= (MAX_SPEED / ACCEL) * delta
	else:
		pass

func _toggle_particles():
	if abs(VELOCITY.x) > SPEED_THRESHOLD:
		SPEED_PARTICLES.emitting = true
	else:
		SPEED_PARTICLES.emitting = false
