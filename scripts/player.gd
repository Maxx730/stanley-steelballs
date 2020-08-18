extends KinematicBody2D

# Global Vars
var MAX_SPEED = 1000
var ACCEL = 10
var CURRENT_SPEED = MAX_SPEED
var YVEL = 0
var JUMP_POWER = -300
var ON_FLOOR = true
var GRAVITY = 9.8
var BOUNCE_DAMPENING = 1.5
var SPEED_PARTICLES = null
var SPEED_THRESHOLD = 500
var BOOSTING = false
var BOOST_TIMEOUT = 3.0
var BOOST_TIMER = 0
var SLOWMO_PART = null
var BOOST_PART = null

#Signals
signal _on_points_gained(value)
signal _on_coins_gained(value)
signal _on_booster_entered(booster)
signal _on_booster_exit(booster)

var VELOCITY = Vector2(MAX_SPEED,0)

func _ready():
	$blink.play("al-blink")
	
	SPEED_PARTICLES = get_node("movement _particle")
	SLOWMO_PART = get_node("slowmo_particle")
	BOOST_PART = get_node("boost-particle")
	
	SLOWMO_PART.emitting = false
	
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
		if BOOSTING == false:
			_decelerate(delta, true)
	else:
		_decelerate(delta, false)
		_apply_gravity()
		
	if BOOSTING && BOOST_TIMER < BOOST_TIMEOUT:
		BOOST_TIMER += delta

func _handle_input():
	if Input.is_action_just_pressed("ui_select") && ON_FLOOR:
		pass

func _apply_gravity():
	VELOCITY.y += GRAVITY
	

func _decelerate(delta, ground):
	if VELOCITY.x > 0:
		if ground:
			VELOCITY.x -= (MAX_SPEED / ACCEL) * delta
		else:
			VELOCITY.x -= (MAX_SPEED / (ACCEL * 3)) * delta
	else:
		pass

func _accelerate(delta):
	VELOCITY.x += 100 * delta

func _toggle_particles():
	if abs(VELOCITY.x) > SPEED_THRESHOLD:
		SPEED_PARTICLES.emitting = true
	else:
		SPEED_PARTICLES.emitting = false
