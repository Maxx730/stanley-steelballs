extends Area2D

var PLAYER = null

func _ready():
	connect("body_entered", self, "_body_entered")
	connect("body_exited", self, "_body_exited")
	
func _process(delta):
	if Input.is_action_just_pressed("ui_select") && PLAYER:
		PLAYER.BOOSTING = true
		PLAYER.BOOST_TIMER = 0
	
func _body_entered(body):
	if body && body.is_in_group('pinball'):
		Engine.time_scale = 0.15
		PLAYER = body
		PLAYER.SLOWMO_PART.emitting = true
		PLAYER.emit_signal('_on_booster_entered', self)
	
func _body_exited(body):
	if body && body.is_in_group('pinball'):
		Engine.time_scale = 1.0
		PLAYER.emit_signal('_on_booster_exit', self)
		PLAYER.SLOWMO_PART.emitting = false
		PLAYER = null
