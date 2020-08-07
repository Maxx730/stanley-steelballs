extends RigidBody2D

var LIGHT = null
var TIME_PERIOD = 1 #2000 ms
var TIME = 0

func _ready():
	LIGHT = get_node("light")
	
func _process(delta):
	TIME += delta
	if TIME > TIME_PERIOD:
		LIGHT.enabled = !LIGHT.enabled
		TIME = 0
