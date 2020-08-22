extends Node

var BACK_BTN = null
var RESET_BTN = null


func _ready():
		BACK_BTN = get_node("canvas/margin/vbox/back-btn")
		RESET_BTN = get_node("canvas/margin/vbox/progress-btn")	
		RESET_BTN.connect('pressed', self, '_reset_progress')
		BACK_BTN.connect('pressed', self, '_go_back')
		
func _reset_progress():
	Global.UTIL.save_data({'coins': 0})
	
func _go_back():
	Global._goto_scene("res://scenes/screens/start.tscn")
