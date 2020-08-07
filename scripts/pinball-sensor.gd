extends Area2D

#global variables
var TRACK_POS = Vector2(0,0)

func _ready():
	set_meta('sensor', true)
	
func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		#check if the sensor is hitting a track or not
		if body.has_meta('track'):
			TRACK_POS = body.global_position
