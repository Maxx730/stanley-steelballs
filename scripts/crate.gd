extends Node

func _ready():
	connect('body_entered', self, '_body_entered')

func _body_entered(body):
	print('crate working')
