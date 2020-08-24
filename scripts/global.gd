extends Node

var CURRENT_SCENE = null

#load util methods
const UTIL = preload("res://scripts/util.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	print('LOADING GLOBAL')
	#start by reading in data, if it does not exist then save new data
	var saved = UTIL.load_data()
	UTIL.save_data(saved)
	CURRENT_SCENE = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	_goto_scene("res://scenes/screens/start.tscn")

func _goto_scene(path):
	call_deferred("_load_scene", path)

func _load_scene(path):
	CURRENT_SCENE.free()
		
	var scene = ResourceLoader.load(path)
	CURRENT_SCENE = scene.instance()
	
	get_tree().get_root().add_child(CURRENT_SCENE)

func _load_main():
	_goto_scene('res://scenes/screens/start.tscn')
