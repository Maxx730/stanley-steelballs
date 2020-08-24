extends Node

var BACK_BUTTON = null
var SCROLL_SCREEN = null

var LEFT = null
var RIGHT = null

var PREVIEW = null
var NAME = null
var PRICE = null
var LOCKED = null
var COINS = null
var CURRENT_SKIN = 0

onready var preskin = load('res://scenes/prefabs/gui/skin-selection.tscn')

func _ready():
	BACK_BUTTON = get_node("canvas/container/VBoxContainer/HBoxContainer/back-button")
	BACK_BUTTON.connect('pressed', self, '_load_main')
	
	LEFT = get_node("canvas/container/VBoxContainer/NinePatchRect/MarginContainer2/MarginContainer/content-container/skins-container/left")
	RIGHT = get_node("canvas/container/VBoxContainer/NinePatchRect/MarginContainer2/MarginContainer/content-container/skins-container/right")
	
	PREVIEW = get_node("canvas/container/VBoxContainer/NinePatchRect/MarginContainer2/MarginContainer/content-container/skins-container/MarginContainer/VBoxContainer/MarginContainer2/skin-preview")
	NAME = get_node("canvas/container/VBoxContainer/NinePatchRect/MarginContainer2/MarginContainer/content-container/skins-container/MarginContainer/VBoxContainer/MarginContainer/skin-name")
	COINS = get_node("canvas/container/VBoxContainer/HBoxContainer/HBoxContainer/coin-amount")
	
	COINS.text = String(Global.UTIL.load_data().coins)
	
	_load_skin(0)
	
	LEFT.connect('pressed', self, '_prev_skin')
	RIGHT.connect('pressed', self, '_next_skin')
	
func _load_main():
	Global._load_main()

func _load_skin(pos):
	var skins = Global.UTIL.SKINS
	var img = load(skins[pos].texture)
	
	NAME.text = skins[pos].name
	PREVIEW.set_texture(img)
	
func _get_active_skin():
	for skin in Global.UTIL.SKINS:
		if skin.selected:
			return skin

func _next_skin():
	if CURRENT_SKIN < Global.UTIL.SKINS.size() - 1:
		CURRENT_SKIN += 1
		_load_skin(CURRENT_SKIN)
	
func _prev_skin():
	if CURRENT_SKIN > 0:
		CURRENT_SKIN -= 1
		_load_skin(CURRENT_SKIN)
	
	
