extends Area2D

#Global Variables
var BOOST_POWER = 0
var BOOST_MAX = 400
var BOOST_MIN = 200

func _ready():
	connect('body_entered', self, '_on_entered')
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	BOOST_POWER = rng.randi_range(BOOST_MIN, BOOST_MAX)
	
func _on_entered(body):
	if body.VELOCITY:
		if body.VELOCITY.x + BOOST_POWER < body.MAX_SPEED:
			body.VELOCITY.x += BOOST_POWER
		else:
			body.VELOCITY.x = body.MAX_SPEED

