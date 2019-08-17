extends "res://Scripts/building.gd"


func _init():
	reference = "res://Scenes/woodcutter.tscn"
	size = 2
	cost = 150
	tile_index = 13
	building_time = 5
	offset = fmod(size,2)
	_name = "Woodcutter hut"
	
