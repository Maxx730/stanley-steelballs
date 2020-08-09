extends Node2D

# Global variables
var PINBALL = null
var MAX_TRACKS = 5;
var TRACK_WIDTH = 0;
var TRACK_AMOUNT = 0;
var TRACK_THRESHHOLD = 3
var TRACK_Y = 0
var ACTIVE_TRACK = 0
var RANDOM_NUM = RandomNumberGenerator.new()
var CAMERA = null
var SCORE = 0
var PAUSED = true
var LAST_POS = null
var POINT_DIVISOR = 10
var COINS = 0

#power meter
var CURRENT_VAL = 0
var MAX_VAL = 100
var POWER_DIR_UP = true

#GUI OBJECTS
var SPEED_LABEL = null
var X_LABEL = null
var Y_LABEL = null
var POWER_METER = null
var SCORE_LABEL = null
var GAMEPLAY_MENU = null
var PAUSE_SHADER = null
var RESUME_BUTTON = null
var COIN_LABEL = null

#DEBUG ELS
var GRAVITY_LABEL = null
var GRAVITY_SLIDER = null
var MAX_SPEED_LABEL = null
var MAX_SPEED_SLIDER = null
var RESET_BUTTON = null
var ZOOM_IN = null
var ZOOM_OUT = null

#Scenes loaded here
var RAMPS = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#creates a new seed for each new game
	randomize()
	
	RAMPS.append(load('res://scenes/prefabs/platforms/ramp-1.tscn'))
	#RAMPS.append(load('res://scenes/prefabs/platforms/ramp-2.tscn'))
	RAMPS.append(load('res://scenes/prefabs/platforms/ramp-3.tscn'))
	#RAMPS.append(load('res://scenes/prefabs/platforms/ramp-4.tscn'))
	#RAMPS.append(load('res://scenes/prefabs/platforms/ramp-6.tscn'))
	#RAMPS.append(load('res://scenes/prefabs/platforms/ramp-7.tscn'))
	#RAMPS.append(load('res://scenes/prefabs/platforms/ramp-8.tscn'))
	#RAMPS.append(load('res://scenes/prefabs/platforms/ramp-9.tscn'))
	
	var labels = get_tree().get_nodes_in_group('gui_label')
	SPEED_LABEL = labels[2]
	X_LABEL = labels[0]
	Y_LABEL = labels[1]
	SCORE_LABEL = labels[4]
	COIN_LABEL = labels[3]
	
	GAMEPLAY_MENU = get_parent().get_node("gui_canvas/gameplay_menu")
	if GAMEPLAY_MENU:
		var menu_buttons = get_tree().get_nodes_in_group("menu_button")
		if menu_buttons:
			RESUME_BUTTON = menu_buttons[0]
			RESUME_BUTTON.connect('pressed', self, '_toggle_pause')
	
	#get the power meter
	var meters = get_tree().get_nodes_in_group('power_bar')
	if meters:
		POWER_METER = meters[0]
	
	PAUSE_SHADER = get_parent().get_node("gui_canvas/menu_shader")
	
	#Create the first platform and add it at 0,0 of the new game
	RANDOM_NUM.randomize()
	var start = RAMPS[0].instance()
	start.position = Vector2(0,TRACK_Y)
	add_child(start)
	TRACK_AMOUNT += 1
	_get_platform_width()
	
	_add_platform()
	_add_platform()
	_add_platform()
	_add_platform()
	_add_platform()
	_add_platform()

	#grab the player pinball here
	PINBALL = get_parent().get_node("al")
	CAMERA = PINBALL.get_node("camera")
	
	PINBALL.connect('_on_points_gained', self, '_add_points')
	PINBALL.connect('_on_coins_gained', self, '_add_coins')
	
	_get_debug_gui()
	
func _draw():
	if PINBALL:
		pass
		#draw_line(Vector2.ZERO, PINBALL.global_position, Color.red)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if PINBALL:
		_check_speed()
		_determine_platform_location()
		
		SPEED_LABEL.text = String(floor(PINBALL.VELOCITY.x / 10)) + 'MPH'
		X_LABEL.text = 'X :: (' + String(floor(PINBALL.global_position.x)) + ')'
		Y_LABEL.text = 'Y :: (' + String(floor(PINBALL.global_position.y)) + ')'
		
		if POWER_METER:
			if CURRENT_VAL <= MAX_VAL && POWER_DIR_UP:
				CURRENT_VAL += 1
			elif CURRENT_VAL == 0:
				POWER_DIR_UP = true
			else:
				POWER_DIR_UP = false
				CURRENT_VAL -= 1
			
			POWER_METER.value = CURRENT_VAL
		
		if TRACK_AMOUNT - ACTIVE_TRACK < TRACK_THRESHHOLD:
			_add_platform()
		
		#Add movement distance to the score
		if LAST_POS && PINBALL.global_position.x - LAST_POS > 0:
			SCORE += (PINBALL.global_position.x - LAST_POS) / POINT_DIVISOR
			
		LAST_POS = PINBALL.global_position.x
		
		if SCORE_LABEL:
			SCORE_LABEL.text = String(floor(SCORE))
		
		update()
		_handle_inputs()
	
func _get_platform_width():
	#grab the first platform that was just added
	var platform = get_child(0)
	TRACK_WIDTH = platform.get_child(0).texture.get_size().x

func _add_platform():
	RANDOM_NUM.randomize()
	var newRamp = RAMPS[RANDOM_NUM.randi_range(0, RAMPS.size() - 1)].instance()
	newRamp.position = Vector2(TRACK_AMOUNT * TRACK_WIDTH, TRACK_Y)
	add_child(newRamp)
	TRACK_AMOUNT += 1

func _determine_platform_location():
	if PINBALL:
		ACTIVE_TRACK = floor(PINBALL.position.x / TRACK_WIDTH)
	else:
		print('ERROR: No pinball object present.')
		
func _reset_tracks():
	for ramp in RAMPS:
			#get_parent().queue_free()
			pass
		
func _check_speed():
	if PINBALL.CURRENT_SPEED < 0:
		PINBALL.global_position = Vector2(0, 0)
		PINBALL.CURRENT_SPEED = PINBALL.MAX_SPEED
		_reset_tracks()

func _get_debug_gui():
	var labels = get_tree().get_nodes_in_group('debug_label')
	var sliders = get_tree().get_nodes_in_group('gui_slider')
	var reset_button = get_tree().get_nodes_in_group('reset_button')
	var zoom_buttons = get_tree().get_nodes_in_group('zoom_button')
	
	if reset_button:
		RESET_BUTTON = reset_button[0]
		RESET_BUTTON.connect('pressed', self, '_reset_pinball')
	
	if labels:
		GRAVITY_LABEL = labels[0]
		GRAVITY_LABEL.text = 'GRAVITY ::: ' + String(PINBALL.GRAVITY)
		
		MAX_SPEED_LABEL = labels[1]
		MAX_SPEED_LABEL.text = 'MAX SPEED ::: ' + String(PINBALL.MAX_SPEED)
	
	if sliders:
		GRAVITY_SLIDER = sliders[0]
		GRAVITY_SLIDER.value = PINBALL.GRAVITY
		GRAVITY_SLIDER.connect('value_changed', self, '_on_gravity_changed')
		
		MAX_SPEED_SLIDER = sliders[1]
		MAX_SPEED_SLIDER.value = PINBALL.MAX_SPEED
		MAX_SPEED_SLIDER.connect('value_changed', self, '_on_max_changed')
	
	if zoom_buttons:
		ZOOM_IN = zoom_buttons[0]
		ZOOM_OUT = zoom_buttons[1]
		
		ZOOM_IN.connect('pressed', self, '_zoom_in')
		ZOOM_OUT.connect('pressed', self, '_zoom_out')

func _on_gravity_changed(value):
	if GRAVITY_LABEL && PINBALL:
		PINBALL.GRAVITY = value
		GRAVITY_LABEL.text = 'GRAVITY ::: ' + String(value)

func _on_max_changed(value):
	if MAX_SPEED_LABEL && PINBALL:
		PINBALL.MAX_SPEED = value
		MAX_SPEED_LABEL.text = 'MAX SPEED ::: ' + String(value)

func _reset_pinball():
	PINBALL.global_position = Vector2(0, 0)
	PINBALL.VELOCITY.x = PINBALL.MAX_SPEED
	
func _zoom_in():
	CAMERA.zoom = Vector2(CAMERA.zoom.x + 0.5, CAMERA.zoom.y + 0.5)
	
func _zoom_out():
	CAMERA.zoom = Vector2(CAMERA.zoom.x - 0.5, CAMERA.zoom.y - 0.5)

func _add_points(value):
	SCORE += value

func _toggle_pause():
	if GAMEPLAY_MENU && PAUSE_SHADER:
		GAMEPLAY_MENU.visible = !GAMEPLAY_MENU.visible
		PAUSE_SHADER.visible = !PAUSE_SHADER.visible
		get_tree().paused = !get_tree().paused

func _handle_inputs():
	if Input.is_action_just_pressed("ui_end"):
		_toggle_pause()

func _add_coins(value):
	COINS += value
	COIN_LABEL.text = 'X ' + String(COINS)
