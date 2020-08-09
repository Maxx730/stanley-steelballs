extends Node

var START_BUTTON = null
var SETTINGS_BUTTON = null
var PLAYER = null

func _ready():
	var buttons = get_tree().get_nodes_in_group('startscreen_button')
	if buttons:
		START_BUTTON = buttons[0]
		SETTINGS_BUTTON = buttons[1]
		
		if START_BUTTON:
			START_BUTTON.connect('pressed', self, '_start_clicked')
			
		if SETTINGS_BUTTON:
			SETTINGS_BUTTON.connect('pressed', self, '_settings_clicked')
			
		#turn the player camera off on main screen
		PLAYER = get_node("al")
		PLAYER.get_node("camera").current = false
		PLAYER.MAX_SPEED = 500
		PLAYER.VELOCITY.x = 500

func _process(delta):
	_check_pinball_pos()

func _start_clicked():
	get_tree().change_scene('res://scenes/gameplay.tscn')
	
func _settings_clicked():
	print('settings_clicked')

func _check_pinball_pos():
	if PLAYER.global_position.x > 800:
		PLAYER.global_position = Vector2(2, 247)
