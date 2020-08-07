extends StaticBody2D

func _ready():
	$reverse_area.connect('body_entered', self, '_object_entered')

func _object_entered(object):
	if object.has_method('_reverse_gravity'):
		object._reverse_gravity()
