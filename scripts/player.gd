extends KinematicBody2D

# Global Vars
var MAX_SPEED = 500
var ACCEL = 10
var GRAVITY = 9.8
var MASS = 45

var POWER = 300
var SPRITE = null

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
	SPRITE = get_node("base/sprite")
	SPEED_PARTICLES = get_node("movement _particle")
	SLOWMO_PART = get_node("slowmo_particle")
	BOOST_PART = get_node("boost-particle")
	
	SLOWMO_PART.emitting = false
	SPEED_PARTICLES.emitting = false
	
	_load_data()

func _physics_process(delta):
	if VELOCITY.x > 0:
		#rotate the sprite based on the speed of the player
		SPRITE.get_parent().rotate(VELOCITY.x * 0.0005)
	
	_handle_input()
	_toggle_particles()
	
	# apply the gravity and increase veocity if right arrow is down
	# only apply gravity if the y value is above a certain amount
	_apply_gravity()
	
	#main touch control the player uses to move forward
	if Input.is_action_pressed("ui_right"):
		if VELOCITY.x < MAX_SPEED && POWER > 0:
			#increase the velocity on arrow now but will change to on touch later
			VELOCITY.x += 10
		
		POWER -= 100 * delta
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
				collision.collider.apply_central_impulse((-collision.normal * MASS * (VELOCITY.x) / 50) / collision.collider.weight)
				#if the player hits the obstacle at a certain speed, destroy it
				if  collision.collider.is_in_group('destructable'):
					VELOCITY.x -= 5
					if (VELOCITY.x / 10) > 40:
						_add_fragment(collision)
						_add_fragment(collision)
						_add_fragment(collision)
		elif collision.collider.is_in_group('ramp'):
			VELOCITY.y -= 3 * GRAVITY


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

func _accelerate(delta):
	VELOCITY.x += 100 * delta

func _toggle_particles():
	if abs(VELOCITY.x) > SPEED_THRESHOLD:
		SPEED_PARTICLES.emitting = true
	else:
		SPEED_PARTICLES.emitting = false

func _load_data():
	#load player data
	var data = Global.UTIL.load_data()
	var img = load(Global.UTIL.SKINS[8].texture)
	
	#set skin variables here
	#MASS = MASS * Global.UTIL.SKINS[4].weight
	#GRAVITY = GRAVITY * Global.UTIL.SKINS[4].weight
	
	#update skin based on data
	SPRITE.set_texture(img)

func _add_fragment(collision):
	var col = collision.collider
	var frag = col.FRAGMENT.instance()
	col.queue_free()
	frag.global_position = collision.position
	frag.apply_central_impulse(Vector2(0, -200))
	get_parent().add_child(frag)
