extends RigidBody2D

var DESPAWN_TIME = 4
var TIME = 0

func _process(delta):
	TIME += delta
	if TIME > DESPAWN_TIME:
		self.queue_free()
