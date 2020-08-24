extends Node

var VALUE_PER_SECOND = 0
var CURR_VAL = 0
var TOTAL_VALUE = null
var TIME = 0
	
func _process(delta):
	#make sure the total has been set before starting the timer
	if TOTAL_VALUE:
		pass		
	
# speed is a value in seconds not ms i.e 1 = 1000ms
func _start_count_up(value, speed):
	TOTAL_VALUE = value
	VALUE_PER_SECOND = value

func _determine_count_progress():
	return CURR_VAL / TOTAL_VALUE
