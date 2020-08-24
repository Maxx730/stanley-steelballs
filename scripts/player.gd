extends KinematicBody2D

# Global Vars
var MAX_SPEED = 500
var ACCEL = 10
var GRAVITY = 9.8
var MASS = 45


var YVEL = 0
var JUMP_POWER = -300
var ON_FLOOR = true
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

var VELOCITY = Vector2(0,0)

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
	#var collision = move_and_collide(VELOCITY * delta)
	#if collision && collision.collider.is_in_group('bumper'):
		#VELOCITY = VELOCITY.bounce(collision.normal) / BOUNCE_DAMPENING
		#emit_signal("_on_points_gained", 1000)
	#elif collision:
		#VELOCITY = VELOCITY.slide(collision.normal)
		#if BOOSTING == false:
			#_decelerate(delta, true)
	#else:
		#_decelerate(delta, false)
		#_apply_gravity()
	
	# apply the gravity and increase veocity if right arrow is down
	# only apply gravity if the y value is above a certain amount
	_apply_gravity()
	
	if Input.is_action_pressed("ui_right") && VELOCITY.x < MAX_SPEED:
		#increase the velocity on arrow now but will change to on touch later
		VELOCITY.x += 10
	else:
		_decelerate(delta, false)
		if VELOCITY.x < 0:
			VELOCITY.x = 0
	
	move_and_slide(VELOCITY,Vector2.UP,
					false, 4, PI/4, false)
					
	#next apply impulses to any colliding bodies
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group('obstacle'):
			# push factor would be the weight of the players chosen skin
			if collision.normal.x < 0:
				collision.collider.apply_central_impulse((-collision.normal * MASS * (VELOCITY.x) / 100) / collision.collider.weight)
				VELOCITY.x -= 10
		elif collision.collider.is_in_group('ramp'):
			VELOCITY.y -= 3 * GRAVITY
		
	if BOOSTING && BOOST_TIMER < BOOST_TIMEOUT:
		BOOST_TIMER += delta

func _handle_input():
	if Input.is_action_just_pressed("ui_select") && ON_FLOOR:
		pass

func _apply_gravity():
	if global_position.y < -1:
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
