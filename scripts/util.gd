extends Node

const SKINS = [{
	"name": "Pinball",
	"texture": "res://sprites/skins/default.png",
	"selected": true,
	"unlocked": true
},{
	"name": "Tennis Ball",
	"texture": "res://sprites/skins/tennisball.png",
	"selected": false,
	"unlocked": false
},{
	"name": "Basketball",
	"texture": "res://sprites/skins/basketball.png",
	"selected": false,
	"unlocked": false
},{
	"name": "Stone",
	"texture": "res://sprites/skins/stone.png",
	"selected": false,
	"unlocked": false
},{
	"name": "Peppermint",
	"texture": "res://sprites/skins/mint.png",
	"selected": false,
	"unlocked": false
},{
	"name": "8 Ball",
	"texture": "res://sprites/skins/8ball.png",
	"selected": false,
	"unlocked": false
},{
	"name": "Orange",
	"texture": "res://sprites/skins/orange.png",
	"selected": false,
	"unlocked": false
},{
	"name": "Big E",
	"texture": "res://sprites/skins/big-ed.png",
	"selected": false,
	"unlocked": false
}]

static func load_data():
	var file = File.new()
	if file.file_exists('user://save_data.data'):
		file.open('user://save_data.data', File.READ)
		var json = parse_json(file.get_line())
		return json
	else:
		#Default saved values if this is the first time someone has played the game.
		return {
			'coins': 0,
			'skin': 0,
			'upgrades': {
				'max_speed': 0,
				'bounce': 0,
				'accel': 0
			}
		}

static func save_data(data):
	var file = File.new()
	file.open('user://save_data.data', File.WRITE)
	file.store_line(to_json(data))
	file.close()
