extends Area2D

var SPRING_POWER = 500
var ANIMATION

func _ready():
	connect('body_entered', self, '_on_player_entered')
	
	ANIMATION = get_node("sprite")
	
func _on_player_entered(player):
	if player && player.VELOCITY:
		player.VELOCITY.y = -SPRING_POWER
		
		if ANIMATION:
			ANIMATION.frame = 1
