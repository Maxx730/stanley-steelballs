extends Area2D

var SPRING_POWER = 500

func _ready():
	connect('body_entered', self, '_on_player_entered')
	
func _on_player_entered(player):
	if player && player.VELOCITY:
		player.VELOCITY.y += -SPRING_POWER
