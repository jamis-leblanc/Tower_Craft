extends "res://Scripts/building.gd"


func _init():
	reference = "res://Scenes/farm.tscn"
	food = 4
	size = 2
	cost = 100
	tile_index = 16
	mouse_offset = fmod(size+1,2) * Vector2(16,16)	# mouse_offset = 16,16 if size is en even number,  0,0 otherwise
	position_offset = fmod(size,2) * Vector2(16,16)	# position_offset = 16,16 if size is en odd number,  0,0 otherwise
	tile_offset = floor(size/2) * Vector2(-1,-1)	# tile_offset = (0,0) is size  = 1, (-1,-1) otherwise
	_name = "Farm"



