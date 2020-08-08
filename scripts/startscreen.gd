extends Node

var START_BUTTON = null
var SETTINGS_BUTTON = null

func _ready():
	var buttons = get_tree().get_nodes_in_group('startscreen_button')
	if buttons:
		START_BUTTON = buttons[0]
		SETTINGS_BUTTON = buttons[1]
		
		if START_BUTTON:
			START_BUTTON.connect('pressed', self, '_start_clicked')
			
		if SETTINGS_BUTTON:
			SETTINGS_BUTTON.connect('pressed', self, '_settings_clicked')

func _start_clicked():
	get_tree().change_scene('res://scenes/gameplay.tscn')
	
func _settings_clicked():
	print('settings_clicked')
