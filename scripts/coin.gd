extends Area2D

func _ready():
	connect('body_entered', self, '_on_object_enter')

func _on_object_enter(obj):
	if obj && obj.is_in_group('pinball'):
		obj.emit_signal('_on_coins_gained', 1)
		obj.emit_signal('_on_points_gained', 10)
		queue_free()
