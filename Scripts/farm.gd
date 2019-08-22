extends "res://Scripts/building.gd"


func _init():
	reference = "res://Scenes/woodcutter.tscn"
	food = 4
	size = 2
	cost = 100
	tile_index = 16
	offset = fmod(size,2)
	_name = "Farm"



