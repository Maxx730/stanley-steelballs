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
var CURRENT_BOOSTER = null

#power meter
var MAX_VAL = 300
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
var QUIT_BUTTON = null
var TAP_BOOST = null
var BOOST_BTN = null
var END_RUN_GUI = null
var TRY_AGAIN = null
var MAIN_MENU = null
var END_COIN_COUNT = null
var END_DISTANCE_COUNT = null
var TOTAL_COINS = null

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

#load util methods
const UTIL = preload("res://scripts/util.gd")
var PROGRESS = null

# Called when the node enters the scene tree for the first time.
func _ready():
	PROGRESS = UTIL.load_data()
	
	#creates a new seed for each new game
	randomize()
	
	RAMPS.append(load('res://scenes/prefabs/platforms/ramp-1.tscn'))
	RAMPS.append(load('res://scenes/prefabs/platforms/ramp-10.tscn'))
	RAMPS.append(load('res://scenes/prefabs/platforms/ramp-3.tscn'))
	RAMPS.append(load('res://scenes/prefabs/platforms/ramp-11.tscn'))
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
	
	var taps = get_tree().get_nodes_in_group('tap_boost')
	if taps:
		TAP_BOOST = taps[0]
		TAP_BOOST.visible = false
	
	var boost_btns = get_tree().get_nodes_in_group('boost_button')
	if boost_btns:
		BOOST_BTN = boost_btns[0]
		BOOST_BTN.visible = false
	
	END_RUN_GUI = get_parent().get_node("gui_canvas/end_run_menu")
	if END_RUN_GUI:
		END_RUN_GUI.visible = false
	
	GAMEPLAY_MENU = get_parent().get_node("gui_canvas/gameplay_menu")
	if GAMEPLAY_MENU:
		var menu_buttons = get_tree().get_nodes_in_group("menu_button")
		if menu_buttons:
			RESUME_BUTTON = menu_buttons[0]
			RESUME_BUTTON.connect('pressed', self, '_toggle_pause')
			QUIT_BUTTON = menu_buttons[1]
			QUIT_BUTTON.connect('pressed', self, '_load_main')
			
	
	var try_again = get_tree().get_nodes_in_group('try_again')
	if try_again:
		TRY_AGAIN = try_again[0]
		TRY_AGAIN.connect('pressed', self, '_reset_pinball')
	
	MAIN_MENU = get_tree().get_nodes_in_group('main_menu')[0]
	MAIN_MENU.connect('pressed', self, '_main_menu')
	
	#get the power meter
	var meters = get_tree().get_nodes_in_group('power_bar')
	if meters:
		POWER_METER = meters[0]
		POWER_METER.max_value = MAX_VAL
		POWER_METER.value = MAX_VAL
	
	PAUSE_SHADER = get_parent().get_node("gui_canvas/menu_shader")
	
	_generate_start()

	#grab the player pinball here
	PINBALL = get_parent().get_node("al")
	CAMERA = PINBALL.get_node("camera")
	
	PINBALL.connect('_on_points_gained', self, '_add_points')
	PINBALL.connect('_on_coins_gained', self, '_add_coins')
	PINBALL.connect('_on_booster_entered', self, '_toggle_boost_tap')
	PINBALL.connect('_on_booster_exit', self, '_booster_exit')
	
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
		
		if PINBALL && PINBALL.POWER > 0 && Input.is_action_pressed("ui_select"):
			POWER_METER.value = PINBALL.POWER
		
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

func _generate_start():
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
	
func _reset_start():
	pass

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
	if PINBALL.VELOCITY.x < 1:
		#PINBALL.global_position = Vector2(0, 0)
		if END_RUN_GUI:
			PINBALL.VELOCITY.x = 0
			END_RUN_GUI.visible = true
			# set ui elements for the end here.
			if !END_COIN_COUNT && !END_DISTANCE_COUNT:
				END_COIN_COUNT = get_tree().get_nodes_in_group('end-coin-count')[0]
				END_DISTANCE_COUNT = get_tree().get_nodes_in_group('end-distance-count')[0]
				TOTAL_COINS = get_tree().get_nodes_in_group('total-coin-count')[0]
				
				END_DISTANCE_COUNT.text = String(floor(SCORE))
				END_COIN_COUNT.text = String(COINS)
				TOTAL_COINS.text = String(PROGRESS.coins)
				
				if END_DISTANCE_COUNT.has_method('_start_count_up'):
					END_DISTANCE_COUNT._start_count_up(SCORE, 2)
				
			if UTIL && PROGRESS:
				UTIL.save_data(PROGRESS)

func _reset_pinball():
	if PINBALL && END_RUN_GUI:
		PINBALL.global_position = Vector2(0, 0)
		PINBALL.VELOCITY.x = PINBALL.MAX_SPEED
		END_RUN_GUI.visible = false

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
		BOOST_BTN.connect('pressed', self, '_boost_player')

func _on_gravity_changed(value):
	if GRAVITY_LABEL && PINBALL:
		PINBALL.GRAVITY = value
		GRAVITY_LABEL.text = 'GRAVITY ::: ' + String(value)

func _on_max_changed(value):
	if MAX_SPEED_LABEL && PINBALL:
		PINBALL.MAX_SPEED = value
		MAX_SPEED_LABEL.text = 'MAX SPEED ::: ' + String(value)
	
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
	pass
		
func _add_coins(value):
	COINS += value
	COIN_LABEL.text = 'X ' + String(COINS)
	if PROGRESS:
		PROGRESS.coins += value

func _load_main():
	get_tree().change_scene('res://scenes/screens/start.tscn')

func _toggle_boost_tap(booster):
	if TAP_BOOST:
		TAP_BOOST.visible = !TAP_BOOST.visible
		BOOST_BTN.visible = !BOOST_BTN.visible
		CURRENT_BOOSTER = booster

func _booster_exit(booster):
	TAP_BOOST.visible = !TAP_BOOST.visible
	BOOST_BTN.visible = !BOOST_BTN.visible
	CURRENT_BOOSTER = null

func _boost_player():
	if PINBALL:
		PINBALL.VELOCITY.x += 300
		PINBALL.BOOST_PART.emitting = true
		CURRENT_BOOSTER.queue_free()

func _main_menu():
	Global._goto_scene('res://scenes/screens/start.tscn')
