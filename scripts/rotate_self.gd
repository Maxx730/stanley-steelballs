extends Node

#Constants
var ROTATION_SPEED = -1
var PARENT = null

func _ready():
	PARENT = get_parent()
	
func _physics_process(delta):
	if PARENT:
		#get_parent().rotate(ROTATION_SPEED)
		pass
