extends "res://Scripts/building.gd"

func _init():
	reference = "res://Scenes/altar.tscn"
	size = 2
	cost = units_stats.altar_cost
	health_max = units_stats.altar_health_max
	$ProgressBar.max_value = health_max
	tile_index = 22
	building_time = 5
	UI_offset = Vector2(64,-64)
	mouse_offset = fmod(size+1,2) * Vector2(16,16)	# mouse_offset = 16,16 if size is en even number,  0,0 otherwise
	position_offset = fmod(size,2) * Vector2(16,16)	# position_offset = 16,16 if size is en odd number,  0,0 otherwise
	tile_offset = floor(size/2) * Vector2(-1,-1)	# tile_offset = (0,0) is size  = 1, (-1,-1) otherwise
	_name = "Altar"
	popup_UI = "res://Scenes/Popup_altar_building.tscn"
	max_user = 5
