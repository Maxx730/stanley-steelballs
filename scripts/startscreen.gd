extends Node

var START_BUTTON = null
var SETTINGS_BUTTON = null
var STORE_BUTTON = null
var PLAYER = null

var TITLE_BACKGROUND = null
var BACKGROUND = null

var FADE_IN_SECONDS = 0.5
var FADE_TIME = 0
var FADE_OFFSET = 0.0

var SLOW_FADE_TIME = 1.0
var SLOW_TIME = 0
var SLOW_OFFSET = 1.5

var PROGRESS = null
var COIN_COUNT = null

#load util methods
const UTIL = preload("res://scripts/util.gd")

func _ready():
	if UTIL:
		PROGRESS = Global.UTIL.load_data()
		COIN_COUNT = get_node("canvas/startmenu/HBoxContainer/HBoxContainer/VBoxContainer/MarginContainer4/HBoxContainer/coin_count")
		COIN_COUNT.text = String(PROGRESS.coins) + '  '
		
	BACKGROUND = get_node("canvas/background_shader").get_material()
	
	START_BUTTON = get_node("canvas/startmenu/HBoxContainer/HBoxContainer/VBoxContainer/MarginContainer/play-button");
	SETTINGS_BUTTON = get_node("canvas").get_node("startmenu/HBoxContainer/HBoxContainer/VBoxContainer/MarginContainer3/settings-button")
	STORE_BUTTON = get_node("canvas/startmenu/HBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/store-button")
		
	if START_BUTTON:
		START_BUTTON.connect('pressed', self, '_start_clicked')
			
	if SETTINGS_BUTTON:
		SETTINGS_BUTTON.connect('pressed', self, '_settings_clicked')
	
	if STORE_BUTTON:
		STORE_BUTTON.connect('pressed', self, '_store_clicked')

func _process(delta):
	BACKGROUND.set_shader_param('grad_offset', .72)

func _start_clicked():
	Global._goto_scene('res://scenes/gameplay.tscn')
	
func _settings_clicked():
	Global._goto_scene('res://scenes/screens/settings.tscn')
	
func _store_clicked():
	Global._goto_scene('res://scenes/screens/store.tscn')
